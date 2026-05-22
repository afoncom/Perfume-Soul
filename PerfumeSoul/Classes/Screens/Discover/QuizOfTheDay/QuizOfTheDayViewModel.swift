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
    var questions: [QuizOfTheDayQuestion] = []
    var currentQuestionIndex = 0
    var scoreToday = 0
    var selectedAnswerId: String?
    var isAnswerSubmitted = false
    var isQuizCompleted = false

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
    }

    func submitAnswer() {
        guard canSubmitAnswer else { return }

        if isSelectedAnswerCorrect {
            scoreToday += 1
        }
        isAnswerSubmitted = true
    }

    func goToNextQuestion() {
        guard canGoToNextQuestion else { return }

        currentQuestionIndex += 1
        selectedAnswerId = nil
        isAnswerSubmitted = false
    }

    func finishQuiz() {
        guard canFinishQuiz else { return }
        isQuizCompleted = true
    }
}
