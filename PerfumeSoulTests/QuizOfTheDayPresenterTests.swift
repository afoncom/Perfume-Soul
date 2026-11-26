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
    func testBankAnswersAndCompletionSurviveBackendUpgradeOnSameDay() async {
        let storage = ViewStateStorage<DailyQuizState>(
            userDefaults: .standard, storableKey: "tests.bankBackendUpgrade.\(UUID().uuidString)"
        )
        defer { storage.clearState() }
        var saved = DailyQuizState.initial(
            quizDayKey: "2026-12-01", questionIDs: [10_001, 10_002], questionSetVersion: .bank
        )
        saved.isCompleted = true
        saved.questionStates[0].selectedAnswerID = "A"
        saved.questionStates[0].isSubmitted = true
        storage.saveState(saved)
        let manager = UpgradingQuizRequestManager()
        let dayProvider = QuizDayKeyProviderMock()
        dayProvider.dayKey = "2026-12-01"
        let viewModel = QuizOfTheDayViewModel()
        let presenter = makePresenter(
            router: QuizOfTheDayRouterMock(),
            viewModel: viewModel,
            service: QuizOfTheDayServiceImpl(requestManager: manager),
            storage: storage,
            dayKeyProvider: dayProvider
        )

        await presenter.onAppear()
        XCTAssertEqual(storage.loadState(), saved)
        manager.supportsCalendar = true
        await presenter.onAppear()

        XCTAssertEqual(storage.loadState(), saved)
        XCTAssertTrue(viewModel.isQuizCompleted)
        XCTAssertEqual(manager.paths, ["/v2/quiz-of-the-day", "/v2/quiz-of-the-day"])
    }

    @MainActor
    func testOldBackendCannotCreateOrOverwriteCalendarSessionBeforeSameDayUpgrade() async throws {
        for hasSavedSession in [false, true] {
            let storage = ViewStateStorage<DailyQuizState>(
                userDefaults: .standard, storableKey: "tests.quizBackendUpgrade.\(UUID().uuidString)"
            )
            defer { storage.clearState() }
            var saved = DailyQuizState.initial(
                quizDayKey: "2026-12-01", questionIDs: [12_001, 12_002], questionSetVersion: .calendar
            )
            saved.isCompleted = true
            saved.questionStates[0].selectedAnswerID = "A"
            saved.questionStates[0].isSubmitted = true
            if hasSavedSession { storage.saveState(saved) }
            let manager = UpgradingQuizRequestManager()
            let dayProvider = QuizDayKeyProviderMock()
            dayProvider.dayKey = "2026-12-01"
            let viewModel = QuizOfTheDayViewModel()
            let presenter = makePresenter(
                router: QuizOfTheDayRouterMock(),
                viewModel: viewModel,
                service: QuizOfTheDayServiceImpl(requestManager: manager),
                storage: storage,
                dayKeyProvider: dayProvider
            )

            await presenter.onAppear()

            XCTAssertEqual(storage.loadState(), hasSavedSession ? saved : nil)
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertEqual(manager.paths, ["/v3/quiz-of-the-day"])

            manager.supportsCalendar = true
            await presenter.onAppear()

            XCTAssertNil(viewModel.errorMessage)
            XCTAssertEqual(viewModel.questions.map(\.id), [12_001, 12_002])
            XCTAssertEqual(storage.loadState()?.questionSetVersion, .calendar)
            if hasSavedSession { XCTAssertEqual(storage.loadState(), saved) }
        }
    }

    @MainActor
    func testCalendarStartsOnDecemberFirstAndPreservesExistingBankSessionUntilNextDay() async throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "tests.quizCalendar.\(UUID().uuidString)"))
        let storage = ViewStateStorage<DailyQuizState>(userDefaults: defaults, storableKey: "quiz")
        defer { storage.clearState() }
        var state = DailyQuizState.initial(
            quizDayKey: "2026-12-01", questionIDs: [10_001, 10_002], questionSetVersion: .bank
        )
        state.isCompleted = true
        storage.saveState(state)
        let service = VersionedQuizServiceMock()
        let dayProvider = QuizDayKeyProviderMock()
        dayProvider.dayKey = "2026-12-01"
        let viewModel = QuizOfTheDayViewModel()
        let presenter = makePresenter(
            router: QuizOfTheDayRouterMock(),
            viewModel: viewModel,
            service: service,
            storage: storage,
            dayKeyProvider: dayProvider
        )

        await presenter.onAppear()
        XCTAssertEqual(storage.loadState(), state)
        XCTAssertEqual(service.requestedVersions, [.bank])
        XCTAssertNil(service.requestedDayKeys[0])

        dayProvider.dayKey = "2026-12-02"
        await presenter.onAppear()
        XCTAssertEqual(storage.loadState()?.questionSetVersion, .calendar)
        XCTAssertEqual(service.requestedDayKeys.last, "2026-12-02")
        XCTAssertFalse(viewModel.isQuizCompleted)
        presenter.selectAnswer(id: "A")
        await presenter.submitAnswer()
        let saved = storage.loadState()
        await presenter.onAppear()
        XCTAssertEqual(storage.loadState(), saved)
        XCTAssertEqual(service.requestedVersions, [.bank, .calendar, .calendar])
        XCTAssertEqual(service.requestedDayKeys, [nil, "2026-12-02", "2026-12-02"])

        storage.clearState()
        dayProvider.dayKey = "2026-12-01"
        await presenter.onAppear()
        XCTAssertEqual(storage.loadState()?.questionSetVersion, .calendar)
        XCTAssertEqual(service.requestedDayKeys.last, "2026-12-01")
    }

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
        let request = QuizOfTheDayRequest(version: .calendar, dayKey: "2026-12-01")
        XCTAssertEqual(request.path, "/v3/quiz-of-the-day")
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "dayKey", value: "2026-12-01")])
        XCTAssertTrue(QuizOfTheDayRequest(version: .bank, dayKey: "2026-12-01").queryItems.isEmpty)
        XCTAssertTrue(QuizOfTheDayRequest(version: .legacy).queryItems.isEmpty)
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

private final class UpgradingQuizRequestManager: RequestManager {
    var supportsCalendar = false
    var paths: [String] = []

    func sendRequest<Response: Decodable>(request: Request) async throws -> Response {
        paths.append(request.path)
        let isCalendar = request.path == "/v3/quiz-of-the-day"
        if isCalendar, !supportsCalendar {
            throw RequestManagerError.clientError(statusCode: 404, reason: "Not Found")
        }
        // The old backend ignores dayKey on v2 and still returns HTTP 200 with bank IDs.
        let ids = isCalendar ? [12_001, 12_002] : [10_001, 10_002]
        let questions: [[String: Any]] = ids.map { id in
            [
                "id": id,
                "question": "Question",
                "explanation": "Explanation",
                "answers": [["id": "A", "text": "Answer", "isCorrect": true]]
            ]
        }
        return try JSONDecoder().decode(Response.self, from: JSONSerialization.data(withJSONObject: questions))
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
    var requestedVersions: [QuizOfTheDayQuestion.SetVersion] = []
    var requestedDayKeys: [String?] = []
    func requestQuizOfTheDayQuestions(
        version: QuizOfTheDayQuestion.SetVersion,
        dayKey: String?
    ) async throws -> [QuizOfTheDayQuestion] {
        requestedVersions.append(version)
        requestedDayKeys.append(dayKey)
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
    func requestQuizOfTheDayQuestions(
        version: QuizOfTheDayQuestion.SetVersion,
        dayKey: String?
    ) async throws -> [QuizOfTheDayQuestion] {
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
