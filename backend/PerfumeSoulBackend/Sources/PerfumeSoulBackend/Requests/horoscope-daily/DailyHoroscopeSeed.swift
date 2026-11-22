import Foundation

struct DailyHoroscopeText: Decodable {
    let ru: String
    let en: String
}

struct DailyHoroscopeDay: Decodable {
    let date: String
    let signs: [String: DailyHoroscopeText]
}

private struct DailyHoroscopeMonth: Decodable {
    let days: [DailyHoroscopeDay]
}

enum DailyHoroscopeSeed {
    static let signs: Set<String> = [
        "aries", "taurus", "gemini", "cancer", "leo", "virgo",
        "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"
    ]

    static func days() throws -> [DailyHoroscopeDay] {
        try validatedMonthlyJSON().flatMap { data in
            try JSONDecoder().decode(DailyHoroscopeMonth.self, from: data).days
        }
    }

    static func validatedMonthlyJSON() throws -> [Data] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let firstDay = calendar.date(from: DateComponents(year: 2026, month: 12, day: 1))!
        let dayAfterLast = calendar.date(from: DateComponents(year: 2028, month: 12, day: 1))!
        var expectedDay = firstDay
        let monthFormatter = formatter("yyyy-MM")
        let dayFormatter = formatter("yyyy-MM-dd")
        var files: [Data] = []

        for monthOffset in 0..<24 {
            let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: firstDay)!
            let month = monthFormatter.string(from: monthDate)
            let resource = "daily-horoscopes-\(month)"
            guard let url = Bundle.module.url(forResource: resource, withExtension: "json") else {
                throw DailyHoroscopeSeedError.missingResource(resource)
            }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DailyHoroscopeMonth.self, from: data)

            for day in decoded.days {
                let validDate = day.date == dayFormatter.string(from: expectedDay)
                let validSigns = Set(day.signs.keys) == signs
                let validTexts = day.signs.values.allSatisfy {
                    !$0.ru.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        && !$0.en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                guard validDate && validSigns && validTexts else {
                    throw DailyHoroscopeSeedError.invalidCatalog(day.date)
                }
                expectedDay = calendar.date(byAdding: .day, value: 1, to: expectedDay)!
            }
            files.append(data)
        }

        guard expectedDay == dayAfterLast else {
            throw DailyHoroscopeSeedError.invalidCatalog("2028-11-30")
        }
        return files
    }

    private static func formatter(_ pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = pattern
        return formatter
    }
}

private enum DailyHoroscopeSeedError: Error {
    case missingResource(String)
    case invalidCatalog(String)
}
