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
    private let onCorrectAnswer: (() -> Void)?
    private let onProgressChange: ((QuizOfTheDayProgress) -> Void)?
    var questions: [QuizOfTheDayQuestion] = []
    var errorMessage: String?
    var currentQuestionIndex: Int
    var scoreToday: Int
    var selectedAnswerId: String?
    var isAnswerSubmitted: Bool
    var isQuizCompleted: Bool

    init(
        progress: QuizOfTheDayProgress = .initial,
        onCorrectAnswer: (() -> Void)? = nil,
        onProgressChange: ((QuizOfTheDayProgress) -> Void)? = nil
    ) {
        self.currentQuestionIndex = progress.currentQuestionIndex
        self.scoreToday = progress.scoreToday
        self.selectedAnswerId = progress.selectedAnswerId
        self.isAnswerSubmitted = progress.isAnswerSubmitted
        self.isQuizCompleted = progress.isQuizCompleted
        self.onCorrectAnswer = onCorrectAnswer
        self.onProgressChange = onProgressChange
    }

    var currentQuestion: QuizOfTheDayQuestion? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    var selectedAnswer: QuizOfTheDayAnswer? {
        currentQuestion?.answers.first(where: { $0.id == selectedAnswerId })
    }

    var hasSelectedAnswer: Bool {
        selectedAnswerId != nil
    }

    var shouldShowExplanation: Bool {
        isAnswerSubmitted
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
        guard !isAnswerSubmitted else { return }
        selectedAnswerId = id
        saveProgress()
    }

    func submitAnswer() {
        guard canSubmitAnswer else { return }

        if isSelectedAnswerCorrect {
            scoreToday += 1
            onCorrectAnswer?()
        }
        isAnswerSubmitted = true
        saveProgress()
    }

    func goToNextQuestion() {
        guard canGoToNextQuestion else { return }

        currentQuestionIndex += 1
        selectedAnswerId = nil
        isAnswerSubmitted = false
        saveProgress()
    }

    func finishQuiz() {
        guard canFinishQuiz else { return }
        isQuizCompleted = true
        saveProgress()
    }

    private func saveProgress() {
        onProgressChange?(
            QuizOfTheDayProgress(
                currentQuestionIndex: currentQuestionIndex,
                scoreToday: scoreToday,
                selectedAnswerId: selectedAnswerId,
                isAnswerSubmitted: isAnswerSubmitted,
                isQuizCompleted: isQuizCompleted
            )
        )
    }
}
