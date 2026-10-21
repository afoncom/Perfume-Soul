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
        quizProgressService: QuizProgressService = QuizProgressServiceMock()
    ) -> QuizOfTheDayPresenterImpl {
        QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router,
            service: QuizOfTheDayServiceMock(),
            dailyQuizStateStorage: ViewStateStorage<DailyQuizState>(
                userDefaults: .standard,
                storableKey: "tests.dailyQuiz.\(UUID().uuidString)"
            ),
            quizProgressService: quizProgressService,
            dayKeyProvider: QuizDayKeyProviderMock()
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

private final class QuizOfTheDayServiceMock: QuizOfTheDayService {
    func requestQuizOfTheDayQuestions() async throws -> [QuizOfTheDayQuestion] {
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
    func todayKey() -> String {
        "2026-08-18"
    }

    func isCurrentOrPreviousDay(_ dayKey: String) -> Bool {
        dayKey == todayKey()
    }

    func isNextDay(_ dayKey: String, after previousDayKey: String) -> Bool {
        false
    }
}
