//
//  QuizDayKeyProvider.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import Foundation

protocol QuizDayKeyProvider {
    func todayKey() -> String
    func isCurrentOrPreviousDay(_ dayKey: String) -> Bool
    func isNextDay(_ dayKey: String, after previousDayKey: String) -> Bool
}

final class QuizDayKeyProviderImpl {
    private let calendar: Calendar
    private let formatter: DateFormatter

    init(calendar: Calendar = .current) {
        self.calendar = calendar

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        self.formatter = formatter
    }

    private func dayKey(for date: Date) -> String {
        formatter.string(from: date)
    }

    private func date(from dayKey: String) -> Date? {
        formatter.date(from: dayKey)
    }
}

extension QuizDayKeyProviderImpl: QuizDayKeyProvider {
    func todayKey() -> String {
        dayKey(for: Date())
    }

    func isCurrentOrPreviousDay(_ dayKey: String) -> Bool {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        return dayKey == self.dayKey(for: today) || dayKey == self.dayKey(for: yesterday)
    }

    func isNextDay(_ dayKey: String, after previousDayKey: String) -> Bool {
        guard let previousDate = date(from: previousDayKey) else {
            return false
        }

        let nextDate = calendar.date(byAdding: .day, value: 1, to: previousDate) ?? previousDate
        return dayKey == self.dayKey(for: nextDate)
    }
}
