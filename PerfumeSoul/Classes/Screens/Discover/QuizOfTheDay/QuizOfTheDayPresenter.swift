//
//  QuizOfTheDayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol QuizOfTheDayPresenter {
    func onAppear() async
    func selectAnswer(id: String)
    @MainActor
    func submitAnswer() async
    func goToNextQuestion()
    // StoreKit review requests must run on the main actor.
    @MainActor
    func quizCompletedCardAppeared()
    @MainActor
    func finishQuiz() async
}

final class QuizOfTheDayPresenterImpl {
    private let viewModel: QuizOfTheDayViewModel
    private let router: QuizOfTheDayRouter
    private let service: QuizOfTheDayService
    private let dailyQuizStateStorage: ViewStateStorage<DailyQuizState>
    private let quizProgressService: QuizProgressService
    private let dayKeyProvider: QuizDayKeyProvider
    private var didCompleteQuizInSession = false
    private var didShowQuizCompletionCard = false
    private var didRequestReviewInSession = false
    
    init(
        viewModel: QuizOfTheDayViewModel,
        router: QuizOfTheDayRouter,
        service: QuizOfTheDayService,
        dailyQuizStateStorage: ViewStateStorage<DailyQuizState>,
        quizProgressService: QuizProgressService,
        dayKeyProvider: QuizDayKeyProvider
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
        self.dailyQuizStateStorage = dailyQuizStateStorage
        self.quizProgressService = quizProgressService
        self.dayKeyProvider = dayKeyProvider
    }
}

extension QuizOfTheDayPresenterImpl: QuizOfTheDayPresenter {
    func onAppear() async {
        let quizProgress = await quizProgressService.loadProgress()

        do {
            let todayKey = dayKeyProvider.todayKey()
            let storedState = dailyQuizStateStorage.loadState()
            let version: QuizOfTheDayQuestion.SetVersion = storedState?.quizDayKey == todayKey
                ? storedState?.questionSetVersion ?? .legacy
                : (todayKey >= "2026-12-01" ? .calendar : .bank)
            let questions = try await service.requestQuizOfTheDayQuestions(
                version: version,
                dayKey: version == .calendar ? todayKey : nil
            )
            let resolvedSession = resolveSession(
                from: questions,
                storedState: storedState,
                todayKey: todayKey,
                version: version
            )
            await MainActor.run {
                viewModel.errorMessage = nil
                viewModel.applySession(
                    questions: resolvedSession.questions,
                    dailyQuizState: resolvedSession.state,
                    quizProgress: quizProgress
                )
            }
        } catch {
            await MainActor.run {
                viewModel.errorMessage = L10n.Common.Error.message
            }
        }
    }

    func selectAnswer(id: String) {
        viewModel.selectAnswer(id: id)
        saveCurrentState()
    }

    @MainActor
    func submitAnswer() async {
        guard let result = viewModel.submitAnswer() else {
            return
        }

        if result.wasCorrect {
            let updatedQuizProgress = await quizProgressService.recordCorrectAnswer(
                questionID: result.questionID,
                quizDayKey: result.quizDayKey
            )
            viewModel.updateQuizProgress(updatedQuizProgress)
        }

        saveCurrentState()
    }

    func goToNextQuestion() {
        viewModel.goToNextQuestion()
        saveCurrentState()
    }

    @MainActor
    func finishQuiz() async {
        guard let quizDayKey = viewModel.finishQuiz() else {
            return
        }

        let updatedQuizProgress = await quizProgressService.completeQuiz(for: quizDayKey)
        viewModel.updateQuizProgress(updatedQuizProgress)
        saveCurrentState()
        router.registerQuizCompletion(for: quizDayKey)
        didCompleteQuizInSession = true
        requestAppReviewIfReady()
    }

    @MainActor
    func quizCompletedCardAppeared() {
        didShowQuizCompletionCard = true
        requestAppReviewIfReady()
    }

    @MainActor
    private func requestAppReviewIfReady() {
        guard
            didCompleteQuizInSession,
            didShowQuizCompletionCard,
            !didRequestReviewInSession
        else {
            return
        }

        didRequestReviewInSession = true
        router.requestAppReviewIfEligible()
    }

    private func resolveSession(
        from questions: [QuizOfTheDayQuestion],
        storedState: DailyQuizState?,
        todayKey: String,
        version: QuizOfTheDayQuestion.SetVersion
    ) -> (questions: [QuizOfTheDayQuestion], state: DailyQuizState) {
        if let storedState {
            if let restoredSession = restoreSession(from: storedState, questions: questions, todayKey: todayKey) {
                dailyQuizStateStorage.saveState(restoredSession.state)
                return restoredSession
            }

            dailyQuizStateStorage.clearState()
        }

        let newState = DailyQuizState.initial(
            quizDayKey: todayKey,
            questionIDs: questions.map(\.id),
            questionSetVersion: version
        )
        dailyQuizStateStorage.saveState(newState)

        return (questions, newState)
    }

    private func restoreSession(
        from state: DailyQuizState,
        questions: [QuizOfTheDayQuestion],
        todayKey: String
    ) -> (questions: [QuizOfTheDayQuestion], state: DailyQuizState)? {
        guard state.quizDayKey == todayKey else {
            return nil
        }

        guard !questions.isEmpty else {
            return nil
        }

        let questionsByID = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
        let orderedQuestions = state.questionIDs.compactMap { questionsByID[$0] }

        guard orderedQuestions.count == state.questionIDs.count else {
            return nil
        }

        var resolvedState = state
        resolvedState.questionSetVersion = state.questionSetVersion ?? .legacy
        resolvedState.currentQuestionIndex = min(
            state.currentQuestionIndex,
            max(orderedQuestions.count - 1, 0)
        )

        return (orderedQuestions, resolvedState)
    }

    private func saveCurrentState() {
        guard let currentDailyQuizState = viewModel.currentDailyQuizState else {
            return
        }

        dailyQuizStateStorage.saveState(currentDailyQuizState)
    }
}
