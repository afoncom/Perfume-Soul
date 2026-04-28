import Foundation

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func loadForToday() throws -> [DailyHoroscope] {
        let today = Date()
        let url = try resourceURL(for: dateKey(for: today))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DailyHoroscope].self, from: data)
    }

    private static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }

    private static func resourceURL(for dateKey: String) throws -> URL {
        if let url = Bundle.module.url(
            forResource: dateKey,
            withExtension: "json",
            subdirectory: "daily-horoscope"
        ) {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
