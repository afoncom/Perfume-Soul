//
//  QuizOfTheDayQuestion.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

import Foundation

struct QuizOfTheDayQuestion {
    let id: Int
    let question: String
    let answers: [QuizOfTheDayAnswer]
    let explanation: String
}

struct QuizOfTheDayAnswer {
    let id: String
    let text: String
    let isCorrect: Bool
}

extension QuizOfTheDayQuestion {
    init(response: QuizOfTheDayResponse) {
        self.id = response.id
        self.question = response.question
        self.answers = response.answers.map { QuizOfTheDayAnswer(response: $0) }
        self.explanation = response.explanation
    }
}

extension QuizOfTheDayAnswer {
    init(response: QuizOfTheDayResponse.Answer) {
        self.id = response.id
        self.text = response.text
        self.isCorrect = response.isCorrect
    }
}
