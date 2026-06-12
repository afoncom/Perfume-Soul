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
    var selectedAnswerId: String?

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
        totalQuestions == 0 ? 0 : Double(currentQuestionNumber) / Double(totalQuestions)
    }

    var progressPercentText: String {
        "\(Int(progressValue * 100))%"
    }

    func isAnswerSelected(_ id: String) -> Bool {
        selectedAnswerId == id
    }

    func selectAnswer(id: String) {
        selectedAnswerId = id
    }

    var progressValue: Double = 0.33
}
