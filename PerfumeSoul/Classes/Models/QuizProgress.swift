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
    var correctQuestionIDs: Set<Int>

    var totalCorrectQuizAnswers: Int {
        correctQuestionIDs.count
    }

    static let initial = QuizProgress(
        streakDays: 0,
        lastCompletedQuizDayKey: nil,
        correctQuestionIDs: []
    )
}
