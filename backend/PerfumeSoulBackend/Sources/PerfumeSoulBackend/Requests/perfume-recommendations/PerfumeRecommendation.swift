import Foundation

struct PerfumeRecommendation: Codable, Equatable {
    let id: UUID
    let perfumeName: String
    let brandName: String
    let accords: [String]
    let matchingNotes: [String]
    let matchPercentage: Int
    let imageUrl: String
}

enum PerfumeRecommendationLoader {
    static func load() throws -> [PerfumeRecommendation] {
        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([PerfumeRecommendation].self, from: data)
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(forResource: "perfume-recommendations", withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
