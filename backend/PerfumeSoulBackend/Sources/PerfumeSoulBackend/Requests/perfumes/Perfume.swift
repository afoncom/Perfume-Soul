import Foundation

struct Perfume: Codable, Equatable {
    let name: String
}

struct PerfumeSearchPage: Codable, Equatable {
    let items: [Perfume]
    let hasMore: Bool
}

enum PerfumeLoader {
    static func load(
        searchText: String,
        offset: Int,
        limit: Int
    ) throws -> PerfumeSearchPage {
        let url = try resourceURL(for: "perfumesList")
        let data = try Data(contentsOf: url)
        let perfumes = try JSONDecoder().decode([Perfume].self, from: data)

        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredPerfumes = perfumes
            .filter { perfume in
                normalizedSearchText.isEmpty
                    || perfume.name.localizedCaseInsensitiveContains(normalizedSearchText)
            }
            .sorted { leftPerfume, rightPerfume in
                leftPerfume.name.localizedCaseInsensitiveCompare(rightPerfume.name) == .orderedAscending
            }

        let startIndex = min(offset, filteredPerfumes.count)
        let endIndex = min(startIndex + limit, filteredPerfumes.count)
        let items = Array(filteredPerfumes[startIndex..<endIndex])

        return PerfumeSearchPage(
            items: items,
            hasMore: endIndex < filteredPerfumes.count
        )
    }

    private static func resourceURL(for resourceName: String) throws -> URL {
        if let url = Bundle.module.url(forResource: resourceName, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
