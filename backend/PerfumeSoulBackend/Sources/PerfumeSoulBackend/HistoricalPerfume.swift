import Foundation
import Vapor

struct PerfumeryHistoryDay: Content, Decodable {
    let dateKey: String
    let title: String
    let items: [PerfumeryHistoryItem]
}

struct PerfumeryHistoryItem: Content, Decodable {
    let year: Int
    let text: String
}

enum PerfumeryHistoryLoader {
    static func load() throws -> PerfumeryHistoryDay {
        let url = Bundle.module.url(forResource: "historical-perfume", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(PerfumeryHistoryDay.self, from: data)
    }
}
