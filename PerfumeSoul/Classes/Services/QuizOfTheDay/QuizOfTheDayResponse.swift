//
//  QuizOfTheDayResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

import Foundation

struct QuizOfTheDayResponse: Decodable {
    let id: Int
    let question: String
    let answers: [Answer]
    let explanation: String

    struct Answer: Decodable {
        let id: String
        let text: String
        let isCorrect: Bool
    }
}
