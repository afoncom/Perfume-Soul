import Foundation

struct PerfumeryHistoryDay: Codable, Equatable {
    let dateKey: String
    let items: [PerfumeryHistoryItem]
}

struct PerfumeryHistoryItem: Codable, Equatable {
    let year: Int
    let text: String
}

enum PerfumeryHistoryLoader {
    static func load(dateKey: String) throws -> [PerfumeryHistoryItem] {
        guard isValidDateKey(dateKey) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        let storage = try JSONDecoder().decode([PerfumeryHistoryDay].self, from: data)

        guard let items = storage.first(where: { $0.dateKey == dateKey })?.items else {
            throw CocoaError(.fileNoSuchFile)
        }

        return items
    }

    private static func isValidDateKey(_ dateKey: String) -> Bool {
        let components = dateKey.split(separator: "-", omittingEmptySubsequences: false)
        return components.count == 2 && components[0].count == 2 && components[1].count == 2
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(
            forResource: "perfumery-history",
            withExtension: "json",
            subdirectory: "perfumery-history"
        ) {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
