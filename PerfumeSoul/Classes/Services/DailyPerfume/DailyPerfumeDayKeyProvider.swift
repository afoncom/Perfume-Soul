//
//  DailyPerfumeDayKeyProvider.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//


import Foundation

protocol DailyPerfumeDayKeyProvider {
    func todayKey() -> String
}

final class DailyPerfumeDayKeyProviderImpl {
    private let formatter: DateFormatter
    private let now: () -> Date

    init(
        calendar: Calendar = Calendar(identifier: .gregorian),
        now: @escaping () -> Date = Date.init
    ) {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"

        self.formatter = formatter
        self.now = now
    }
}

extension DailyPerfumeDayKeyProviderImpl: DailyPerfumeDayKeyProvider {
    func todayKey() -> String {
        formatter.string(from: now())
    }
}
