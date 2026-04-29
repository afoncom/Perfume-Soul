import Foundation

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load() throws -> [DailyHoroscope] {
        let url = try resourceURL(for: "04-18")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DailyHoroscope].self, from: data)
    }

    private static func resourceURL(for dateKey: String) throws -> URL {
        if let url = Bundle.module.url(forResource: dateKey, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
