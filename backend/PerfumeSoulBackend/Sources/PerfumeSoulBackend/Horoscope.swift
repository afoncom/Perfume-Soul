import Foundation

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let date: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load(date: String) throws -> [DailyHoroscope] {
        let url = try resourceURL(for: date)
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([StoredDailyHoroscope].self, from: data)

        return entries.map {
            DailyHoroscope(
                sign: $0.sign,
                date: date,
                energyOfDay: $0.energyOfDay
            )
        }
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

private struct StoredDailyHoroscope: Decodable {
    let sign: String
    let energyOfDay: String
}
