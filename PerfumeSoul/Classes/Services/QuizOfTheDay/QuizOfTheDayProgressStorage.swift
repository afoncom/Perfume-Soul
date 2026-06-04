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
    let streakDays: Int
    let selectedAnswerId: String?
    let isAnswerSubmitted: Bool
    let isQuizCompleted: Bool

    static let initial = QuizOfTheDayProgress(
        currentQuestionIndex: 0,
        scoreToday: 0,
        streakDays: 0,
        selectedAnswerId: nil,
        isAnswerSubmitted: false,
        isQuizCompleted: false
    )
}

protocol QuizOfTheDayProgressStorage {
    func loadProgress() -> QuizOfTheDayProgress
    func saveProgress(_ progress: QuizOfTheDayProgress)
    func completeQuiz()
}

final class QuizOfTheDayProgressStorageImpl {
    private enum Keys {
        static let date = "quizOfTheDay.date"
        static let currentQuestionIndex = "quizOfTheDay.currentQuestionIndex"
        static let scoreToday = "quizOfTheDay.scoreToday"
        static let streakDays = "quizOfTheDay.streakDays"
        static let lastCompletedDate = "quizOfTheDay.lastCompletedDate"
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
        dayKey(for: Date())
    }

    private func dayKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return "\(year)-\(month)-\(day)"
    }

    private var yesterdayKey: String {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return dayKey(for: yesterday)
    }

    private func resolvedStreakDays() -> Int {
        let streakDays = userDefaults.integer(forKey: Keys.streakDays)
        guard let lastCompletedDate = userDefaults.string(forKey: Keys.lastCompletedDate) else {
            return 0
        }

        guard lastCompletedDate == todayKey || lastCompletedDate == yesterdayKey else {
            return 0
        }

        return streakDays
    }
}

extension QuizOfTheDayProgressStorageImpl: QuizOfTheDayProgressStorage {
    func loadProgress() -> QuizOfTheDayProgress {
        let streakDays = resolvedStreakDays()

        guard userDefaults.string(forKey: Keys.date) == todayKey else {
            return QuizOfTheDayProgress(
                currentQuestionIndex: 0,
                scoreToday: 0,
                streakDays: streakDays,
                selectedAnswerId: nil,
                isAnswerSubmitted: false,
                isQuizCompleted: false
            )
        }

        return QuizOfTheDayProgress(
            currentQuestionIndex: userDefaults.integer(forKey: Keys.currentQuestionIndex),
            scoreToday: userDefaults.integer(forKey: Keys.scoreToday),
            streakDays: streakDays,
            selectedAnswerId: userDefaults.string(forKey: Keys.selectedAnswerId),
            isAnswerSubmitted: userDefaults.bool(forKey: Keys.isAnswerSubmitted),
            isQuizCompleted: userDefaults.bool(forKey: Keys.isQuizCompleted)
        )
    }

    func saveProgress(_ progress: QuizOfTheDayProgress) {
        userDefaults.set(todayKey, forKey: Keys.date)
        userDefaults.set(progress.currentQuestionIndex, forKey: Keys.currentQuestionIndex)
        userDefaults.set(progress.scoreToday, forKey: Keys.scoreToday)
        userDefaults.set(progress.streakDays, forKey: Keys.streakDays)
        userDefaults.set(progress.selectedAnswerId, forKey: Keys.selectedAnswerId)
        userDefaults.set(progress.isAnswerSubmitted, forKey: Keys.isAnswerSubmitted)
        userDefaults.set(progress.isQuizCompleted, forKey: Keys.isQuizCompleted)
    }

    func completeQuiz() {
        let newStreakDays: Int
        let currentStreakDays = resolvedStreakDays()
        let lastCompletedDate = userDefaults.string(forKey: Keys.lastCompletedDate)

        if lastCompletedDate == yesterdayKey {
            newStreakDays = currentStreakDays + 1
        } else if lastCompletedDate == todayKey {
            newStreakDays = currentStreakDays
        } else {
            newStreakDays = 1
        }

        userDefaults.set(newStreakDays, forKey: Keys.streakDays)
        userDefaults.set(todayKey, forKey: Keys.lastCompletedDate)
    }
}
