import Fluent
import Foundation

struct Perfume: Codable, Equatable {
    let name: String
}

struct PerfumeSearchPage: Codable, Equatable {
    let items: [Perfume]
    let hasMore: Bool
}

struct PerfumeNotesResponse: Codable, Equatable {
    let id: Int
    let brand: String
    let perfumeName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}

enum PerfumeLoader {
    static func load(
        on database: any Database,
        searchText: String,
        offset: Int,
        limit: Int
    ) async throws -> PerfumeSearchPage {
        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let upperBound = offset + limit + 1

        let query = PerfumeModel.query(on: database)
            .with(\.$brand)
            .join(parent: \.$brand)
            .sort(BrandModel.self, \.$name)
            .sort(\.$perfumeName)
            .range(offset..<upperBound)

        if !normalizedSearchText.isEmpty {
            let pattern = "%\(normalizedSearchText.escapedForLikePattern)%"
            query.group(.or) { group in
                group.filter(\.$perfumeName, .custom("ilike"), pattern)
                    .filter(BrandModel.self, \.$name, .custom("ilike"), pattern)
            }
        }

        let perfumes = try await query.all()
        let hasMore = perfumes.count > limit
        let items = perfumes
            .prefix(limit)
            .map(Perfume.init(model:))

        return PerfumeSearchPage(
            items: Array(items),
            hasMore: hasMore
        )
    }
}

enum PerfumeNotesLoader {
    static func load(
        perfumeID: Int,
        on database: any Database
    ) async throws -> PerfumeNotesResponse? {
        guard let perfume = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .filter(\.$id == perfumeID)
            .first()
        else {
            return nil
        }

        let perfumeNotes = try await PerfumeNoteModel.query(on: database)
            .with(\.$note)
            .filter(\.$perfume.$id == perfumeID)
            .sort(\.$sortOrder)
            .all()

        var topNotes: [String] = []
        var middleNotes: [String] = []
        var baseNotes: [String] = []

        for perfumeNote in perfumeNotes {
            switch perfumeNote.noteType {
            case .top:
                topNotes.append(perfumeNote.note.name)
            case .middle:
                middleNotes.append(perfumeNote.note.name)
            case .base:
                baseNotes.append(perfumeNote.note.name)
            }
        }

        guard let id = perfume.id else {
            return nil
        }

        return PerfumeNotesResponse(
            id: id,
            brand: perfume.brand.name,
            perfumeName: perfume.perfumeName,
            longevityScore: perfume.longevityScore,
            sillageScore: perfume.sillageScore,
            topNotes: topNotes,
            middleNotes: middleNotes,
            baseNotes: baseNotes
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

private extension String {
    var escapedForLikePattern: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }
}
