import Foundation

struct PerfumeryHistorySeedEntry: Decodable {
    let dateKey: String
    let eventYear: Int
    let titleRu: String
    let titleEn: String
    let fullStoryRu: String
    let fullStoryEn: String
}

enum PerfumeryHistorySeed {
    static func entries() throws -> [PerfumeryHistorySeedEntry] {
        guard let url = Bundle.module.url(forResource: "perfumery-history", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }

        return try JSONDecoder().decode(
            [PerfumeryHistorySeedEntry].self,
            from: Data(contentsOf: url)
        )
    }
}
