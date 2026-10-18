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
}

extension QuizProgress: DatabaseStorable {
    init?(storableModel: CDQuizProgress) {
        self.streakDays = Int(storableModel.streakDays)
        self.lastCompletedQuizDayKey = storableModel.lastCompletedQuizDayKey
        self.correctAnswerKeys = Self.decodeCorrectAnswerKeys(storableModel.correctAnswerKeys)
    }
}

extension CDQuizProgress: CDModel {
    func update(by model: QuizProgress) {
        self.streakDays = Int16(clamping: model.streakDays)
        self.lastCompletedQuizDayKey = model.lastCompletedQuizDayKey
        self.correctAnswerKeys = QuizProgress.encodeCorrectAnswerKeys(model.correctAnswerKeys)
    }
}

extension QuizProgress {
    var totalCorrectQuizAnswers: Int {
        correctAnswerKeys.count
    }

    static let initial = QuizProgress(
        streakDays: 0,
        lastCompletedQuizDayKey: nil,
        correctAnswerKeys: []
    )

    fileprivate static func decodeCorrectAnswerKeys(_ value: String?) -> Set<String> {
        guard
            let value,
            let data = value.data(using: .utf8),
            let keys = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }

        return Set(keys)
    }

    fileprivate static func encodeCorrectAnswerKeys(_ keys: Set<String>) -> String? {
        guard let data = try? JSONEncoder().encode(keys.sorted()) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
