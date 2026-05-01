import Foundation

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load() throws -> [DailyHoroscope] {
        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DailyHoroscope].self, from: data)
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(forResource: "04-18", withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
