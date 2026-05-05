import Foundation

struct PerfumeryHistoryItem: Codable, Equatable {
    let year: Int
    let namePerfume: String
    let shortStory: String
    let fullStory: String
    let image: String
}

enum PerfumeryHistoryLoader {
    static func load() throws -> [PerfumeryHistoryItem] {
        let url = try resourceURL(for: "2026-04-18")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([PerfumeryHistoryItem].self, from: data)
    }

    private static func resourceURL(for dateKey: String) throws -> URL {
        if let url = Bundle.module.url(forResource: dateKey, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
