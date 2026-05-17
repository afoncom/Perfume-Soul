//
//  QuizOfTheDayViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation
import CoreGraphics

@Observable final class QuizOfTheDayViewModel {
    var questions: [QuizOfTheDayQuestion] = []
    var currentQuestionIndex = 0

    var currentQuestion: QuizOfTheDayQuestion? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        questions.count
    }

    var currentQuestionNumber: Int {
        totalQuestions == 0 ? 0 : currentQuestionIndex + 1
    }

    var progressValue: CGFloat {
        totalQuestions == 0 ? 0 : CGFloat(currentQuestionNumber) / CGFloat(totalQuestions)
    }

    var progressPercentText: String {
        "\(Int(progressValue * 100))%"
    }
}
