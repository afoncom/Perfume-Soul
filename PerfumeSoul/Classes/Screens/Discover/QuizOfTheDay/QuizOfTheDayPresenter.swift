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
    func submitAnswer()
    func goToNextQuestion()
    func finishQuiz()
}

final class QuizOfTheDayPresenterImpl {
    private let viewModel: QuizOfTheDayViewModel
    private let router: QuizOfTheDayRouter
    private let service: QuizOfTheDayService
    private let dailyQuizStateStorage: DailyQuizStateStorage
    private let quizProgressService: QuizProgressService
    private let dayKeyProvider: QuizDayKeyProvider
    
    init(
        viewModel: QuizOfTheDayViewModel,
        router: QuizOfTheDayRouter,
        service: QuizOfTheDayService,
        dailyQuizStateStorage: DailyQuizStateStorage,
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
        let quizProgress = quizProgressService.loadProgress()

        do {
            let questions = try await service.requestQuizOfTheDayQuestions()
            let resolvedSession = resolveSession(from: questions)
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

    func submitAnswer() {
        guard let result = viewModel.submitAnswer() else { return }

        if result.wasCorrect {
            let updatedQuizProgress = quizProgressService.recordCorrectAnswer(
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

    func finishQuiz() {
        guard let quizDayKey = viewModel.finishQuiz() else { return }

        let updatedQuizProgress = quizProgressService.completeQuiz(for: quizDayKey)
        viewModel.updateQuizProgress(updatedQuizProgress)
        saveCurrentState()
    }

    private func resolveSession(from questions: [QuizOfTheDayQuestion]) -> (questions: [QuizOfTheDayQuestion], state: DailyQuizState) {
        let todayKey = dayKeyProvider.todayKey()

        if let storedState = dailyQuizStateStorage.loadState() {
            if let restoredSession = restoreSession(from: storedState, questions: questions, todayKey: todayKey) {
                return restoredSession
            }

            dailyQuizStateStorage.clearState()
        }

        let newState = DailyQuizState.initial(
            quizDayKey: todayKey,
            questionIDs: questions.map(\.id)
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
        resolvedState.currentQuestionIndex = min(
            state.currentQuestionIndex,
            max(orderedQuestions.count - 1, 0)
        )

        return (orderedQuestions, resolvedState)
    }

    private func saveCurrentState() {
        guard let currentDailyQuizState = viewModel.currentDailyQuizState else { return }
        dailyQuizStateStorage.saveState(currentDailyQuizState)
    }
}
