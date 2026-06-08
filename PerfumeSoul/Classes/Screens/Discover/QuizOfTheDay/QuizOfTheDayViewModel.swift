//
//  QuizOfTheDayViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

@Observable final class QuizOfTheDayViewModel {
    private var dailyQuizState: DailyQuizState?
    private var quizProgress: QuizProgress
    var questions: [QuizOfTheDayQuestion] = []
    var errorMessage: String?

    init(quizProgress: QuizProgress = .initial) {
        self.quizProgress = quizProgress
    }

    func applySession(
        questions: [QuizOfTheDayQuestion],
        dailyQuizState: DailyQuizState,
        quizProgress: QuizProgress
    ) {
        self.questions = questions
        self.dailyQuizState = dailyQuizState
        self.quizProgress = quizProgress
    }

    var currentDailyQuizState: DailyQuizState? {
        dailyQuizState
    }

    var currentQuestion: QuizOfTheDayQuestion? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    private var currentQuestionState: DailyQuizQuestionState? {
        guard let questionID = currentQuestion?.id else { return nil }
        return dailyQuizState?.questionState(for: questionID)
    }

    var selectedAnswer: QuizOfTheDayAnswer? {
        currentQuestion?.answers.first(where: { $0.id == selectedAnswerId })
    }

    var currentQuestionIndex: Int {
        dailyQuizState?.currentQuestionIndex ?? 0
    }

    var scoreToday: Int {
        dailyQuizState?.questionStates.filter { $0.isSubmitted && $0.wasCorrect }.count ?? 0
    }

    var streakDays: Int {
        quizProgress.streakDays
    }

    var selectedAnswerId: String? {
        currentQuestionState?.selectedAnswerID
    }

    var isAnswerSubmitted: Bool {
        currentQuestionState?.isSubmitted ?? false
    }

    var isQuizCompleted: Bool {
        dailyQuizState?.isCompleted ?? false
    }

    var hasSelectedAnswer: Bool {
        selectedAnswerId != nil
    }

    var canSubmitAnswer: Bool {
        !isAnswerSubmitted && hasSelectedAnswer
    }

    var canGoToNextQuestion: Bool {
        isAnswerSubmitted && currentQuestionIndex + 1 < totalQuestions
    }

    var isOnLastQuestion: Bool {
        totalQuestions > 0 && currentQuestionIndex == totalQuestions - 1
    }

    var canFinishQuiz: Bool {
        isAnswerSubmitted && isOnLastQuestion && !isQuizCompleted
    }

    var isSelectedAnswerCorrect: Bool {
        selectedAnswer?.isCorrect == true
    }

    var totalQuestions: Int {
        questions.count
    }

    var currentQuestionNumber: Int {
        totalQuestions == 0 ? 0 : currentQuestionIndex + 1
    }

    var progressValue: Double {
        totalQuestions == 0 ? 0 : (isQuizCompleted ? 1 : Double(currentQuestionNumber) / Double(totalQuestions))
    }

    var progressPercentText: String {
        "\(Int(progressValue * 100))%"
    }

    func isAnswerSelected(_ id: String) -> Bool {
        selectedAnswerId == id
    }

    func selectAnswer(id: String) {
        guard !isAnswerSubmitted, let questionID = currentQuestion?.id else { return }
        updateDailyQuizState { state in
            state.updateQuestionState(questionID: questionID) { questionState in
                questionState.selectedAnswerID = id
            }
        }
    }

    func submitAnswer() -> (questionID: Int, wasCorrect: Bool)? {
        guard
            canSubmitAnswer,
            let question = currentQuestion
        else {
            return nil
        }

        let wasCorrect = isSelectedAnswerCorrect

        updateDailyQuizState { state in
            state.updateQuestionState(questionID: question.id) { questionState in
                questionState.isSubmitted = true
                questionState.wasCorrect = wasCorrect
            }
        }

        return (question.id, wasCorrect)
    }

    func goToNextQuestion() {
        guard canGoToNextQuestion else { return }

        updateDailyQuizState { state in
            state.currentQuestionIndex += 1
        }
    }

    func finishQuiz() -> String? {
        guard
            canFinishQuiz,
            let quizDayKey = dailyQuizState?.quizDayKey
        else {
            return nil
        }

        updateDailyQuizState { state in
            state.isCompleted = true
        }

        return quizDayKey
    }

    func updateQuizProgress(_ quizProgress: QuizProgress) {
        self.quizProgress = quizProgress
    }

    private func updateDailyQuizState(_ update: (inout DailyQuizState) -> Void) {
        guard var dailyQuizState else { return }
        update(&dailyQuizState)
        self.dailyQuizState = dailyQuizState
    }
}
