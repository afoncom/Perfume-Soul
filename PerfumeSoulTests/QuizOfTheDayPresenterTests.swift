//
//  QuizOfTheDayPresenterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 18.08.2026.
//

import Observation
import XCTest
@testable import PerfumeSoul

final class QuizOfTheDayPresenterTests: XCTestCase {
    @MainActor
    func testLegacySessionsKeepAnswersAndCompletionUntilTheNextDay() async throws {
        for completed in [false, true] {
            let suiteName = "tests.quizTransition.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
            defer { defaults.removePersistentDomain(forName: suiteName) }
            let storage = ViewStateStorage<DailyQuizState>(userDefaults: defaults, storableKey: "quiz")
            let legacyJSON = """
                {"quizDayKey":"2026-08-18","questionIDs":[1,2],"currentQuestionIndex":1,
                "questionStates":[
                    {"questionID":1,"selectedAnswerID":"A","isSubmitted":true,"wasCorrect":true},
                    {"questionID":2,"selectedAnswerID":"B","isSubmitted":true,"wasCorrect":false}
                ],"isCompleted":\(completed)}
                """
            defaults.set(Data(legacyJSON.utf8), forKey: "quiz")
            var expected = try XCTUnwrap(storage.loadState())
            let viewModel = QuizOfTheDayViewModel()
            let dayProvider = QuizDayKeyProviderMock()
            let presenter = makePresenter(
                router: QuizOfTheDayRouterMock(),
                viewModel: viewModel,
                service: VersionedQuizServiceMock(),
                storage: storage,
                dayKeyProvider: dayProvider
            )

            await presenter.onAppear()

            expected.questionSetVersion = .legacy
            XCTAssertEqual(viewModel.currentDailyQuizState, expected)
            XCTAssertEqual(storage.loadState(), expected)
            XCTAssertEqual(viewModel.questions.map(\.id), [1, 2])

            dayProvider.dayKey = "2026-08-19"
            await presenter.onAppear()

            XCTAssertEqual(viewModel.questions.map(\.id), [10_001, 10_002])
            XCTAssertEqual(storage.loadState()?.questionSetVersion, .bank)
            XCTAssertFalse(viewModel.isQuizCompleted)
            XCTAssertEqual(viewModel.currentQuestionIndex, 0)
        }
    }

    @MainActor
    func testNewBankSessionRestoresTheSameSetAndAnswers() async throws {
        let suiteName = "tests.quizBank.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let storage = ViewStateStorage<DailyQuizState>(userDefaults: defaults, storableKey: "quiz")
        let viewModel = QuizOfTheDayViewModel()
        let presenter = makePresenter(
            router: QuizOfTheDayRouterMock(),
            viewModel: viewModel,
            service: VersionedQuizServiceMock(),
            storage: storage
        )

        await presenter.onAppear()
        presenter.selectAnswer(id: "A")
        await presenter.submitAnswer()
        let savedState = try XCTUnwrap(storage.loadState())
        await presenter.onAppear()

        XCTAssertEqual(viewModel.questions.map(\.id), [10_001, 10_002])
        XCTAssertEqual(savedState.questionSetVersion, .bank)
        XCTAssertEqual(viewModel.currentDailyQuizState, savedState)
        XCTAssertEqual(viewModel.selectedAnswerId, "A")
        XCTAssertTrue(viewModel.isAnswerSubmitted)
    }

    func testQuizRequestsUseSeparateEndpointsForEachSet() {
        XCTAssertEqual(QuizOfTheDayRequest(version: .legacy).path, "/quiz-of-the-day")
        XCTAssertEqual(QuizOfTheDayRequest(version: .bank).path, "/v2/quiz-of-the-day")
    }

    @MainActor
    func testCompletedCardAppearanceWithoutQuizCompletionDoesNotRequestReview() {
        let router = QuizOfTheDayRouterMock()
        let presenter = makePresenter(router: router)

        presenter.quizCompletedCardAppeared()

        XCTAssertFalse(router.didRequestAppReview)
        XCTAssertTrue(router.registeredQuizDayKeys.isEmpty)
    }

    @MainActor
    func testCompletedCardAppearanceAfterQuizCompletionRequestsReview() async {
        let router = QuizOfTheDayRouterMock()
        let presenter = makePresenter(router: router)

        await presenter.onAppear()
        presenter.selectAnswer(id: "A")
        await presenter.submitAnswer()
        await presenter.finishQuiz()
        presenter.quizCompletedCardAppeared()

        XCTAssertTrue(router.didRequestAppReview)
        XCTAssertEqual(router.registeredQuizDayKeys, ["2026-08-18"])
    }

    @MainActor
    func testCompletionRequestsReviewWhenCardAppearsWhileProgressIsSaving() async {
        let router = QuizOfTheDayRouterMock()
        let quizProgressService = DelayedQuizProgressServiceMock()
        let presenter = makePresenter(
            router: router,
            quizProgressService: quizProgressService
        )

        await presenter.onAppear()
        presenter.selectAnswer(id: "A")
        await presenter.submitAnswer()
        let finishTask = Task { @MainActor in
            await presenter.finishQuiz()
        }
        await quizProgressService.waitUntilCompletionStarts()
        presenter.quizCompletedCardAppeared()

        XCTAssertFalse(router.didRequestAppReview)

        await quizProgressService.resumeCompletion()
        await finishTask.value

        XCTAssertTrue(router.didRequestAppReview)
        XCTAssertEqual(router.registeredQuizDayKeys, ["2026-08-18"])
    }

    @MainActor
    func testSubmitAnswerChangesObservedScreenStateOnMainThread() async {
        let viewModel = QuizOfTheDayViewModel()
        let presenter = makePresenter(
            router: QuizOfTheDayRouterMock(),
            viewModel: viewModel
        )
        await presenter.onAppear()
        presenter.selectAnswer(id: "A")
        var didObserveChange = false
        var observationRanOnMainThread = false
        withObservationTracking {
            _ = viewModel.isAnswerSubmitted
        } onChange: {
            didObserveChange = true
            observationRanOnMainThread = Thread.isMainThread
        }

        await presenter.submitAnswer()

        XCTAssertTrue(didObserveChange)
        XCTAssertTrue(observationRanOnMainThread)
        XCTAssertTrue(viewModel.isAnswerSubmitted)
    }

    private func makePresenter(
        router: QuizOfTheDayRouterMock,
        viewModel: QuizOfTheDayViewModel = QuizOfTheDayViewModel(),
        quizProgressService: QuizProgressService = QuizProgressServiceMock(),
        service: QuizOfTheDayService = QuizOfTheDayServiceMock(),
        storage: ViewStateStorage<DailyQuizState>? = nil,
        dayKeyProvider: QuizDayKeyProvider = QuizDayKeyProviderMock()
    ) -> QuizOfTheDayPresenterImpl {
        QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router,
            service: service,
            dailyQuizStateStorage: storage ?? ViewStateStorage<DailyQuizState>(
                userDefaults: .standard,
                storableKey: "tests.dailyQuiz.\(UUID().uuidString)"
            ),
            quizProgressService: quizProgressService,
            dayKeyProvider: dayKeyProvider
        )
    }
}

private actor DelayedQuizProgressServiceMock: QuizProgressService {
    private var progress = QuizProgress.initial
    private var completionStartedContinuation: CheckedContinuation<Void, Never>?
    private var completionResumeContinuation: CheckedContinuation<Void, Never>?
    private var didStartCompletion = false

    func loadProgress() -> QuizProgress { progress }

    func recordCorrectAnswer(questionID: Int, quizDayKey: String) -> QuizProgress {
        progress.correctAnswerKeys.insert("\(quizDayKey)_\(questionID)")
        return progress
    }

    func completeQuiz(for quizDayKey: String) async -> QuizProgress {
        didStartCompletion = true
        completionStartedContinuation?.resume()
        completionStartedContinuation = nil
        await withCheckedContinuation { continuation in
            completionResumeContinuation = continuation
        }
        progress.lastCompletedQuizDayKey = quizDayKey
        progress.streakDays = 1
        return progress
    }

    func resetProgress() {
        progress = .initial
    }

    func waitUntilCompletionStarts() async {
        if didStartCompletion {
            return
        }
        await withCheckedContinuation { continuation in
            completionStartedContinuation = continuation
        }
    }

    func resumeCompletion() {
        completionResumeContinuation?.resume()
        completionResumeContinuation = nil
    }
}

private final class QuizOfTheDayRouterMock: QuizOfTheDayRouter {
    var registeredQuizDayKeys: [String] = []
    var didRequestAppReview = false

    @MainActor
    func registerQuizCompletion(for quizDayKey: String) {
        registeredQuizDayKeys.append(quizDayKey)
    }

    @MainActor
    func requestAppReviewIfEligible() {
        didRequestAppReview = true
    }
}

private final class VersionedQuizServiceMock: QuizOfTheDayService {
    func requestQuizOfTheDayQuestions(version: QuizOfTheDayQuestion.SetVersion) async throws -> [QuizOfTheDayQuestion] {
        let ids = version == .legacy ? [1, 2] : [10_001, 10_002]
        return ids.map { id in
            QuizOfTheDayQuestion(
                id: id,
                question: "Question \(id)",
                answers: [
                    QuizOfTheDayAnswer(id: "A", text: "Correct", isCorrect: true),
                    QuizOfTheDayAnswer(id: "B", text: "Incorrect", isCorrect: false)
                ],
                explanation: "Explanation"
            )
        }
    }
}

private final class QuizOfTheDayServiceMock: QuizOfTheDayService {
    func requestQuizOfTheDayQuestions(version: QuizOfTheDayQuestion.SetVersion) async throws -> [QuizOfTheDayQuestion] {
        [
            QuizOfTheDayQuestion(
                id: 1,
                question: "Which note is citrus?",
                answers: [
                    QuizOfTheDayAnswer(id: "A", text: "Bergamot", isCorrect: true),
                    QuizOfTheDayAnswer(id: "B", text: "Sandalwood", isCorrect: false)
                ],
                explanation: "Bergamot is a citrus note."
            )
        ]
    }
}

private final class QuizProgressServiceMock: QuizProgressService {
    private var progress = QuizProgress.initial

    func loadProgress() async -> QuizProgress {
        progress
    }

    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress {
        progress.correctAnswerKeys.insert("\(quizDayKey)_\(questionID)")
        return progress
    }

    func completeQuiz(for quizDayKey: String) async -> QuizProgress {
        progress.lastCompletedQuizDayKey = quizDayKey
        progress.streakDays = 1
        return progress
    }

    func resetProgress() async {
        progress = .initial
    }
}

private final class QuizDayKeyProviderMock: QuizDayKeyProvider {
    var dayKey = "2026-08-18"

    func todayKey() -> String {
        dayKey
    }

    func isCurrentOrPreviousDay(_ dayKey: String) -> Bool {
        dayKey == todayKey()
    }

    func isNextDay(_ dayKey: String, after previousDayKey: String) -> Bool {
        false
    }
}
