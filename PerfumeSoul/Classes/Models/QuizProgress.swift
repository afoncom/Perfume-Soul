//
//  QuizProgress.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import Foundation

struct QuizProgress: Codable, Equatable {
    var streakDays: Int
    var lastCompletedQuizDayKey: String?
    var correctAnswerKeys: Set<String>

    var totalCorrectQuizAnswers: Int {
        correctAnswerKeys.count
    }

    static let initial = QuizProgress(
        streakDays: 0,
        lastCompletedQuizDayKey: nil,
        correctAnswerKeys: []
    )
}
