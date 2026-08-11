import Fluent
import Foundation

struct Perfume: Codable, Equatable {
    let id: Int
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
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let longevityScore: Int?
    let sillageScore: Int?
    let releaseYear: Int?
    let perfumer: String?
    let shortDescription: String?
    let recommendationReason: String?
    let fullStory: String?
    let accords: [PerfumeAccordResponse]
    let notesLanguage: String
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}

struct PerfumeAccordResponse: Codable, Equatable {
    let name: String
    let weight: Double
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
            .compactMap(Perfume.init(model:))

        return PerfumeSearchPage(
            items: Array(items),
            hasMore: hasMore
        )
    }
}

enum PerfumeNotesLoader {
    static func load(
        perfumeID: Int,
        on database: any Database,
        language: String? = nil
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
        let perfumeAccords = try await PerfumeAccordModel.query(on: database)
            .with(\.$accord)
            .filter(\.$perfume.$id == perfumeID)
            .all()

        var topNotes: [String] = []
        var middleNotes: [String] = []
        var baseNotes: [String] = []
        let isEnglish = Self.prefersEnglish(acceptLanguage: language)
        let useEnglishNotes = isEnglish && !perfumeNotes.isEmpty && perfumeNotes.allSatisfy {
            $0.note.nameEnglish?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
        if isEnglish, !useEnglishNotes {
            database.logger.notice("[perfumes] serving Russian notes for English request perfumeID=\(perfumeID)")
        }
        let accords = perfumeAccords
            .sorted { lhs, rhs in
                if lhs.weight == rhs.weight {
                    return lhs.accord.name < rhs.accord.name
                }

                return lhs.weight > rhs.weight
            }
            .map {
                PerfumeAccordResponse(
                    name: $0.accord.name,
                    weight: $0.weight
                )
            }

        for perfumeNote in perfumeNotes {
            let noteName: String
            if useEnglishNotes, let englishName = perfumeNote.note.nameEnglish {
                noteName = englishName
            } else {
                noteName = perfumeNote.note.name
            }

            switch perfumeNote.noteType {
            case .top:
                topNotes.append(noteName)
            case .middle:
                middleNotes.append(noteName)
            case .base:
                baseNotes.append(noteName)
            }
        }

        guard let id = perfume.id else {
            return nil
        }

        return PerfumeNotesResponse(
            id: id,
            brand: perfume.brand.name,
            perfumeName: perfume.perfumeName,
            concentration: perfume.concentration,
            fragranceFamily: perfume.fragranceFamily,
            seasonProfile: perfume.seasonProfile,
            occasionProfile: perfume.occasionProfile,
            styleProfile: perfume.styleProfile,
            genderProfile: perfume.genderProfile,
            moodProfile: perfume.moodProfile,
            longevityScore: perfume.longevityScore,
            sillageScore: perfume.sillageScore,
            releaseYear: perfume.releaseYear,
            perfumer: perfume.perfumer,
            shortDescription: isEnglish
                ? perfume.shortDescriptionEnglish
                : perfume.shortDescription,
            recommendationReason: isEnglish
                ? perfume.recommendationReasonEnglish
                : perfume.recommendationReason,
            fullStory: isEnglish
                ? perfume.fullStoryEnglish
                : perfume.fullStory,
            accords: accords,
            notesLanguage: useEnglishNotes ? "en" : "ru",
            topNotes: topNotes,
            middleNotes: middleNotes,
            baseNotes: baseNotes
        )
    }

    static func prefersEnglish(acceptLanguage: String?) -> Bool {
        acceptLanguage?
            .lowercased()
            .split(separator: ",")
            .first?
            .trimmingCharacters(in: .whitespaces)
            .hasPrefix("en") == true
    }
}

extension Perfume {
    fileprivate init?(model: PerfumeModel) {
        guard let id = model.id else {
            return nil
        }

        self.id = id

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

extension String {
    fileprivate var escapedForLikePattern: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }
}
