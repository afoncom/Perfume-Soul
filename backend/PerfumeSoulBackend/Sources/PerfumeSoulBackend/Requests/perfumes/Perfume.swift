import Fluent
import Foundation
import Vapor

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
    let imageURL: String?
    let imageSource: String?
}

struct FragellaFragrance: Decodable {
    let name: String
    let brand: String
    let imageURL: String?
    let concentration: String?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case brand = "Brand"
        case imageURL = "Image URL"
        case concentration = "OilType"
    }
}

enum FragellaImageLookup {
    static func lookup(client: any Client, apiKey: String?, brand: String, name: String, concentration: String?) async throws -> String? {
        guard let apiKey, !apiKey.isEmpty, name.count >= 3 else {
            return nil
        }
        var components = URLComponents(string: "https://api.fragella.com/api/v1/fragrances")
        components?.queryItems = [
            URLQueryItem(name: "search", value: name),
            URLQueryItem(name: "limit", value: "10")
        ]
        guard let url = components?.url else {
            return nil
        }
        let response = try await client.get(URI(string: url.absoluteString)) { request in
            request.headers.add(name: "x-api-key", value: apiKey)
        }
        guard response.status == .ok else {
            throw Abort(.badGateway, reason: "Image provider is unavailable.")
        }
        let matches = try response.content.decode([FragellaFragrance].self)
        return imageURL(in: matches, brand: brand, name: name, concentration: concentration)
    }

    static func imageURL(
        in matches: [FragellaFragrance],
        brand: String,
        name: String,
        concentration: String? = nil
    ) -> String? {
        let expectedBrand = normalized(brand)
        let expectedName = normalized(name)
        let match = matches.first { match in
            let matchBrand = normalized(match.brand)
            let brandMatches = matchBrand == expectedBrand
                || (expectedBrand == "dior" && matchBrand == "christian dior")
            let matchName = normalized(match.name)
            let unbrandedName = matchName.hasPrefix(expectedBrand + " ")
                ? String(matchName.dropFirst(expectedBrand.count + 1)) : matchName
            let concentrationMatches = concentration == nil || match.concentration == nil
                || normalized(concentration ?? "") == normalized(match.concentration ?? "")
            return brandMatches
                && (matchName == expectedName || unbrandedName == expectedName)
                && concentrationMatches
                && validImageURL(match.imageURL)
        }
        return match?.imageURL
    }

    private static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func validImageURL(_ value: String?) -> Bool {
        guard let value, let url = URLComponents(string: value) else {
            return false
        }
        return url.scheme == "https" && url.host == "cdn.fragella.com"
            && url.path.hasPrefix("/images/") && url.user == nil && url.password == nil
    }
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
            .field(\.$id)
            .field(\.$perfumeName)
            .field(\.$brand.$id)
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
        if isEnglish, !useEnglishNotes, !perfumeNotes.isEmpty {
            database.logger.debug("[perfumes] serving Russian notes for English request perfumeID=\(perfumeID)")
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
            if useEnglishNotes,
                let englishName = perfumeNote.note.nameEnglish?.trimmingCharacters(in: .whitespacesAndNewlines) {
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
            baseNotes: baseNotes,
            imageURL: nil,
            imageSource: nil
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
