//
//  QuizOfTheDayPresenterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 18.08.2026.
//

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
        presenter.submitAnswer()
        presenter.finishQuiz()
        presenter.quizCompletedCardAppeared()

        XCTAssertTrue(router.didRequestAppReview)
        XCTAssertEqual(router.registeredQuizDayKeys, ["2026-08-18"])
    }

    private func makePresenter(
        router: QuizOfTheDayRouterMock
    ) -> QuizOfTheDayPresenterImpl {
        QuizOfTheDayPresenterImpl(
            viewModel: QuizOfTheDayViewModel(),
            router: router,
            service: QuizOfTheDayServiceMock(),
            dailyQuizStateStorage: DailyQuizStateStorageMock(),
            quizProgressService: QuizProgressServiceMock(),
            dayKeyProvider: QuizDayKeyProviderMock()
        )
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

private final class DailyQuizStateStorageMock: DailyQuizStateStorage {
    private var state: DailyQuizState?

    func loadState() -> DailyQuizState? {
        state
    }

    func saveState(_ state: DailyQuizState) {
        self.state = state
    }

    func clearState() {
        state = nil
    }
}

private final class QuizProgressServiceMock: QuizProgressService {
    private var progress = QuizProgress.initial

    func loadProgress() -> QuizProgress {
        progress
    }

    func recordCorrectAnswer(questionID: Int, quizDayKey: String) -> QuizProgress {
        progress.correctAnswerKeys.insert("\(quizDayKey)_\(questionID)")
        return progress
    }

    func completeQuiz(for quizDayKey: String) -> QuizProgress {
        progress.lastCompletedQuizDayKey = quizDayKey
        progress.streakDays = 1
        return progress
    }

    func resetProgress() {
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
