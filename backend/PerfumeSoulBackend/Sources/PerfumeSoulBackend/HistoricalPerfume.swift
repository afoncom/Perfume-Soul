import Foundation

struct PerfumeryHistoryItem: Codable, Equatable {
    let year: Int
    let text: String
}

enum PerfumeryHistoryLoader {
    static func load(dateKey: String) throws -> [PerfumeryHistoryItem] {
        guard isValidDateKey(dateKey) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let url = try resourceURL(for: dateKey)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([PerfumeryHistoryItem].self, from: data)
    }

    private static func isValidDateKey(_ dateKey: String) -> Bool {
        let components = dateKey.split(separator: "-", omittingEmptySubsequences: false)
        return components.count == 3
            && components[0].count == 4
            && components[1].count == 2
            && components[2].count == 2
    }

    private static func resourceURL(for dateKey: String) throws -> URL {
        if let url = Bundle.module.url(
            forResource: dateKey,
            withExtension: "json",
            subdirectory: "perfumery-history"
        ) {
            return url
        }

        if let url = Bundle.module.url(forResource: dateKey, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
