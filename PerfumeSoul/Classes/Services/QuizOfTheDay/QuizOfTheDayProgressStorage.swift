//
//  QuizOfTheDayProgressStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 04.06.2026.
//

import Foundation

struct QuizOfTheDayProgress {
    let currentQuestionIndex: Int
    let scoreToday: Int
    let selectedAnswerId: String?
    let isAnswerSubmitted: Bool
    let isQuizCompleted: Bool

    static let initial = QuizOfTheDayProgress(
        currentQuestionIndex: 0,
        scoreToday: 0,
        selectedAnswerId: nil,
        isAnswerSubmitted: false,
        isQuizCompleted: false
    )
}

protocol QuizOfTheDayProgressStorage {
    func loadProgress() -> QuizOfTheDayProgress
    func saveProgress(_ progress: QuizOfTheDayProgress)
}

final class QuizOfTheDayProgressStorageImpl {
    private enum Keys {
        static let date = "quizOfTheDay.date"
        static let currentQuestionIndex = "quizOfTheDay.currentQuestionIndex"
        static let scoreToday = "quizOfTheDay.scoreToday"
        static let selectedAnswerId = "quizOfTheDay.selectedAnswerId"
        static let isAnswerSubmitted = "quizOfTheDay.isAnswerSubmitted"
        static let isQuizCompleted = "quizOfTheDay.isQuizCompleted"
    }

    private let userDefaults: UserDefaults
    private let calendar: Calendar

    init(
        userDefaults: UserDefaults,
        calendar: Calendar = .current
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
    }

    private var todayKey: String {
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return "\(year)-\(month)-\(day)"
    }
}

extension QuizOfTheDayProgressStorageImpl: QuizOfTheDayProgressStorage {
    func loadProgress() -> QuizOfTheDayProgress {
        guard userDefaults.string(forKey: Keys.date) == todayKey else {
            return .initial
        }

        return QuizOfTheDayProgress(
            currentQuestionIndex: userDefaults.integer(forKey: Keys.currentQuestionIndex),
            scoreToday: userDefaults.integer(forKey: Keys.scoreToday),
            selectedAnswerId: userDefaults.string(forKey: Keys.selectedAnswerId),
            isAnswerSubmitted: userDefaults.bool(forKey: Keys.isAnswerSubmitted),
            isQuizCompleted: userDefaults.bool(forKey: Keys.isQuizCompleted)
        )
    }

    func saveProgress(_ progress: QuizOfTheDayProgress) {
        userDefaults.set(todayKey, forKey: Keys.date)
        userDefaults.set(progress.currentQuestionIndex, forKey: Keys.currentQuestionIndex)
        userDefaults.set(progress.scoreToday, forKey: Keys.scoreToday)
        userDefaults.set(progress.selectedAnswerId, forKey: Keys.selectedAnswerId)
        userDefaults.set(progress.isAnswerSubmitted, forKey: Keys.isAnswerSubmitted)
        userDefaults.set(progress.isQuizCompleted, forKey: Keys.isQuizCompleted)
    }
}
