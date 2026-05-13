import Foundation

struct ListPerfume: Codable, Equatable {
    let id: UUID
    let perfumeName: String
    let brandName: String
    let accords: [String]
    let matchingNotes: [String]
    let matchPercentage: Int
    let imageUrl: String
}

enum ListPerfumeLoader {
    static func load() throws -> [ListPerfume] {
        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ListPerfume].self, from: data)
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(forResource: "list-perfume", withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
