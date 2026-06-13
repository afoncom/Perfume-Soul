import Fluent

struct Perfume: Codable, Equatable {
    let name: String
}

struct PerfumeSearchPage: Codable, Equatable {
    let items: [Perfume]
    let hasMore: Bool
}

enum PerfumeLoader {
    static func load(
        on database: any Database,
        searchText: String,
        offset: Int,
        limit: Int
    ) async throws -> PerfumeSearchPage {
        let perfumes = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .all()

        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredPerfumes = perfumes
            .map(Perfume.init(model:))
            .filter { perfume in
                normalizedSearchText.isEmpty
                    || perfume.name.localizedCaseInsensitiveContains(normalizedSearchText)
            }
            .sorted { leftPerfume, rightPerfume in
                leftPerfume.name.localizedCaseInsensitiveCompare(rightPerfume.name) == .orderedAscending
            }

        let startIndex = min(offset, filteredPerfumes.count)
        let pageSize = min(limit, filteredPerfumes.count - startIndex)
        let endIndex = startIndex + pageSize
        let items = Array(filteredPerfumes[startIndex..<endIndex])

        return PerfumeSearchPage(
            items: items,
            hasMore: endIndex < filteredPerfumes.count
        )
    }
}

private extension Perfume {
    init(model: PerfumeModel) {
        let brandName = model.brand.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let perfumeName = model.perfumeName.trimmingCharacters(in: .whitespacesAndNewlines)

        if perfumeName.localizedCaseInsensitiveContains(brandName), !brandName.isEmpty {
            self.name = perfumeName
        } else if brandName.isEmpty {
            self.name = perfumeName
        } else if perfumeName.isEmpty {
            self.name = brandName
        } else {
            self.name = "\(brandName) \(perfumeName)"
        }
    }
}
