import Foundation

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load(date: String) throws -> [DailyHoroscope] {
        let url = try resourceURL(for: date)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DailyHoroscope].self, from: data)
    }

    private static func resourceURL(for date: String) throws -> URL {
        if let url = Bundle.module.url(
            forResource: date,
            withExtension: "json",
            subdirectory: "daily-horoscope"
        ) {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
