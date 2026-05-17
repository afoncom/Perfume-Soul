import Foundation

struct SimilarPerfume: Codable, Equatable {
    let id: UUID
    let perfumeName: String
    let brandName: String
    let accords: [String]
    let matchingNotes: [String]
    let matchPercentage: Int
    let imageUrl: String
}

enum SimilarPerfumeLoader {
    static func load() throws -> [SimilarPerfume] {
        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([SimilarPerfume].self, from: data)
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(forResource: "similar-perfume", withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
