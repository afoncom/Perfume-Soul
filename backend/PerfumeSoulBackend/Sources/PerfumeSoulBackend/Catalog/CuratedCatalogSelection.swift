import Foundation

struct CatalogSourcePerfume: Equatable, Sendable {
    let sourceURL: String
    let perfumeName: String
    let brandName: String
    let country: String
    let gender: String
    let rating: Double
    let ratingCount: Int
    let releaseYear: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
    let perfumers: [String]
    let accords: [String]

    var hasCompleteMatchingProfile: Bool {
        !normalized(perfumeName).isEmpty
            && !normalized(brandName).isEmpty
            && !topNotes.isEmpty
            && !middleNotes.isEmpty
            && !baseNotes.isEmpty
            && canonicalAccords.count >= 3
    }

    var canonicalAccords: [String] {
        CatalogAccordNormalizer.normalize(accords)
    }

    var normalizedIdentity: String {
        "\(normalized(brandName))|\(normalized(perfumeName))"
    }
}

enum CatalogSourcePerfumeParser {
    static func parse(_ csv: String) throws -> [CatalogSourcePerfume] {
        let lines = csv
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .newlines) }
        guard let headerLine = lines.first else {
            return []
        }

        let header = parseLine(headerLine)
        let headerPositions = Dictionary(
            uniqueKeysWithValues: header.enumerated().map { ($0.element, $0.offset) }
        )
        try validateHeaders(headerPositions)

        return lines.dropFirst().compactMap { line in
            let values = parseLine(line)
            guard !values.allSatisfy({ normalized($0).isEmpty }) else {
                return nil
            }

            func value(_ field: String) -> String {
                guard let position = headerPositions[field], values.indices.contains(position) else {
                    return ""
                }
                return values[position].trimmingCharacters(in: .whitespacesAndNewlines)
            }

            return CatalogSourcePerfume(
                sourceURL: value("url"),
                perfumeName: value("Perfume"),
                brandName: value("Brand"),
                country: value("Country"),
                gender: value("Gender"),
                rating: Double(value("Rating Value").replacingOccurrences(of: ",", with: ".")) ?? 0,
                ratingCount: Int(value("Rating Count")) ?? 0,
                releaseYear: Int(value("Year")),
                topNotes: list(from: value("Top")),
                middleNotes: list(from: value("Middle")),
                baseNotes: list(from: value("Base")),
                perfumers: [value("Perfumer1"), value("Perfumer2")].filter {
                    !normalized($0).isEmpty && normalized($0) != "unknown"
                },
                accords: [
                    value("mainaccord1"),
                    value("mainaccord2"),
                    value("mainaccord3"),
                    value("mainaccord4"),
                    value("mainaccord5")
                ].filter { !normalized($0).isEmpty }
            )
        }
    }

    private static func validateHeaders(_ positions: [String: Int]) throws {
        let requiredHeaders = [
            "url", "Perfume", "Brand", "Country", "Gender", "Rating Value", "Rating Count", "Year",
            "Top", "Middle", "Base", "Perfumer1", "Perfumer2", "mainaccord1", "mainaccord2",
            "mainaccord3", "mainaccord4", "mainaccord5"
        ]
        guard requiredHeaders.allSatisfy({ positions[$0] != nil }) else {
            throw CatalogSourcePerfumeParserError.missingRequiredHeaders
        }
    }

    private static func list(from value: String) -> [String] {
        value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !normalized($0).isEmpty }
    }

    private static func parseLine(_ line: String) -> [String] {
        var fields: [String] = []
        var field = ""
        var isInsideQuotes = false
        var index = line.startIndex

        while index < line.endIndex {
            let character = line[index]
            if character == "\"" {
                let nextIndex = line.index(after: index)
                if isInsideQuotes, nextIndex < line.endIndex, line[nextIndex] == "\"" {
                    field.append(character)
                    index = nextIndex
                } else {
                    isInsideQuotes.toggle()
                }
            } else if character == ";", !isInsideQuotes {
                fields.append(field)
                field = ""
            } else {
                field.append(character)
            }
            index = line.index(after: index)
        }

        fields.append(field)
        return fields
    }
}

enum CatalogSourcePerfumeParserError: Error, Equatable {
    case missingRequiredHeaders
}

struct CatalogSelectionPolicy: Sendable {
    let targetCount: Int
    let maximumPerBrand: Int

    init(targetCount: Int, maximumPerBrand: Int) {
        self.targetCount = max(targetCount, 0)
        self.maximumPerBrand = max(maximumPerBrand, 1)
    }
}

struct CatalogSelectionResult: Sendable {
    let selected: [CatalogSourcePerfume]
    let rejected: [CatalogSelectionRejection]
}

struct CatalogSelectionRejection: Sendable {
    let perfume: CatalogSourcePerfume
    let reason: CatalogSelectionRejectionReason
}

enum CatalogSelectionRejectionReason: Sendable, Equatable {
    case incompleteProfile
    case duplicateOfStrongerRecord
    case brandCapReached
    case targetReached
}

enum CuratedCatalogSelector {
    static func select(
        from sourcePerfumes: [CatalogSourcePerfume],
        policy: CatalogSelectionPolicy
    ) -> CatalogSelectionResult {
        var rejected: [CatalogSelectionRejection] = []
        let completePerfumes = sourcePerfumes.filter { perfume in
            guard perfume.hasCompleteMatchingProfile else {
                rejected.append(CatalogSelectionRejection(perfume: perfume, reason: .incompleteProfile))
                return false
            }
            return true
        }

        let deduplicated = strongestPerfumesByIdentity(
            completePerfumes,
            rejected: &rejected
        )
        let ranked = deduplicated.sorted(by: ranksBefore)
        var brandCounts: [String: Int] = [:]
        var selected: [CatalogSourcePerfume] = []

        for perfume in ranked {
            guard selected.count < policy.targetCount else {
                rejected.append(CatalogSelectionRejection(perfume: perfume, reason: .targetReached))
                continue
            }

            let brand = normalized(perfume.brandName)
            let count = brandCounts[brand, default: 0]
            guard count < policy.maximumPerBrand else {
                rejected.append(CatalogSelectionRejection(perfume: perfume, reason: .brandCapReached))
                continue
            }

            selected.append(perfume)
            brandCounts[brand] = count + 1
        }

        return CatalogSelectionResult(selected: selected, rejected: rejected)
    }

    private static func strongestPerfumesByIdentity(
        _ perfumes: [CatalogSourcePerfume],
        rejected: inout [CatalogSelectionRejection]
    ) -> [CatalogSourcePerfume] {
        var winners: [String: CatalogSourcePerfume] = [:]

        for perfume in perfumes {
            let identity = perfume.normalizedIdentity
            guard let currentWinner = winners[identity] else {
                winners[identity] = perfume
                continue
            }

            if ranksBefore(perfume, currentWinner) {
                rejected.append(CatalogSelectionRejection(perfume: currentWinner, reason: .duplicateOfStrongerRecord))
                winners[identity] = perfume
            } else {
                rejected.append(CatalogSelectionRejection(perfume: perfume, reason: .duplicateOfStrongerRecord))
            }
        }

        return Array(winners.values)
    }

    private static func ranksBefore(_ lhs: CatalogSourcePerfume, _ rhs: CatalogSourcePerfume) -> Bool {
        if lhs.ratingCount != rhs.ratingCount {
            return lhs.ratingCount > rhs.ratingCount
        }
        if lhs.rating != rhs.rating {
            return lhs.rating > rhs.rating
        }
        if lhs.releaseYear != rhs.releaseYear {
            return (lhs.releaseYear ?? 0) > (rhs.releaseYear ?? 0)
        }
        if normalized(lhs.brandName) != normalized(rhs.brandName) {
            return normalized(lhs.brandName) < normalized(rhs.brandName)
        }
        if normalized(lhs.perfumeName) != normalized(rhs.perfumeName) {
            return normalized(lhs.perfumeName) < normalized(rhs.perfumeName)
        }
        return lhs.sourceURL < rhs.sourceURL
    }
}

enum CatalogAccordNormalizer {
    static func normalize(_ sourceAccords: [String]) -> [String] {
        var seen = Set<String>()

        return sourceAccords.compactMap { sourceAccord in
            let value = normalized(sourceAccord)
            guard !value.isEmpty else {
                return nil
            }

            let canonical = aliases[value] ?? value
            guard controlledAccords.contains(canonical) else {
                return nil
            }
            return seen.insert(canonical).inserted ? canonical : nil
        }
    }

    private static let aliases: [String: String] = [
        "white floral": "floral",
        "yellow floral": "floral",
        "green floral": "floral",
        "warm spicy": "spicy",
        "fresh spicy": "spicy",
        "soft spicy": "spicy",
        "aquatic": "marine",
        "ozonic": "marine",
        "watery": "marine",
        "sweet": "gourmand",
        "vanilla": "gourmand",
        "caramel": "gourmand",
        "coffee": "gourmand",
        "cacao": "gourmand",
        "chocolate": "gourmand",
        "mossy": "earthy",
        "balsamic": "resinous",
        "oud": "resinous",
        "animalic": "musky",
        "soapy": "fresh",
        "aldehydic": "fresh",
        "almond": "gourmand",
        "anis": "aromatic",
        "asphalt": "marine",
        "beeswax": "gourmand",
        "camphor": "aromatic",
        "cannabis": "green",
        "champagne": "boozy",
        "cherry": "fruity",
        "cinnamon": "spicy",
        "coca-cola": "gourmand",
        "coconut": "gourmand",
        "conifer": "woody",
        "herbal": "aromatic",
        "honey": "gourmand",
        "iris": "floral",
        "lactonic": "gourmand",
        "lavender": "aromatic",
        "mineral": "marine",
        "nutty": "gourmand",
        "patchouli": "earthy",
        "rose": "floral",
        "rum": "boozy",
        "salty": "marine",
        "tobacco": "smoky",
        "tropical": "fruity",
        "tuberose": "floral",
        "violet": "floral",
        "vodka": "boozy",
        "whiskey": "boozy",
        "wine": "boozy"
    ]

    static func isRecognized(_ sourceAccord: String) -> Bool {
        let canonical = aliases[normalized(sourceAccord)] ?? normalized(sourceAccord)
        return controlledAccords.contains(canonical)
    }

    private static let controlledAccords: Set<String> = [
        "amber", "aromatic", "boozy", "citrus", "earthy", "floral", "fresh", "fruity",
        "gourmand", "green", "leather", "marine", "musky", "powdery", "resinous", "smoky",
        "spicy", "woody"
    ]
}

struct CatalogImportAuditReport: Codable, Sendable {
    let sourcePerfumeCount: Int
    let selectedPerfumeCount: Int
    let rejectedCountByReason: [String: Int]
    let selectedCountByBrand: [String: Int]
    let unmappedAccords: [String: Int]
}

enum CatalogImportAudit {
    static func makeReport(
        sourcePerfumes: [CatalogSourcePerfume],
        policy: CatalogSelectionPolicy
    ) -> CatalogImportAuditReport {
        let selection = CuratedCatalogSelector.select(
            from: sourcePerfumes,
            policy: policy
        )
        let rejectedCountByReason = Dictionary(grouping: selection.rejected, by: { rejection in
            switch rejection.reason {
            case .incompleteProfile:
                return "incomplete_profile"
            case .duplicateOfStrongerRecord:
                return "duplicate_of_stronger_record"
            case .brandCapReached:
                return "brand_cap_reached"
            case .targetReached:
                return "target_reached"
            }
        }).mapValues(\.count)
        let selectedCountByBrand = Dictionary(grouping: selection.selected, by: \.brandName)
            .mapValues(\.count)
        let unmappedAccords = sourcePerfumes
            .flatMap(\.accords)
            .filter { !CatalogAccordNormalizer.isRecognized($0) }
            .reduce(into: [String: Int]()) { counts, accord in
                counts[normalized(accord), default: 0] += 1
            }

        return CatalogImportAuditReport(
            sourcePerfumeCount: sourcePerfumes.count,
            selectedPerfumeCount: selection.selected.count,
            rejectedCountByReason: rejectedCountByReason,
            selectedCountByBrand: selectedCountByBrand,
            unmappedAccords: unmappedAccords
        )
    }
}

struct CatalogPreparedPerfume: Sendable {
    let brandName: String
    let perfumeName: String
    let genderProfile: String
    let releaseYear: Int?
    let perfumer: String?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
    let accords: [String]
    let longevityScore: Int?
    let sillageScore: Int?
    let marketSegment: String

    var identity: String {
        "\(normalized(brandName))|\(normalized(perfumeName))"
    }

    init(source: CatalogSourcePerfume) throws {
        guard source.hasCompleteMatchingProfile else {
            throw CatalogPreparedPerfumeError.incompleteMatchingProfile
        }

        self.brandName = CatalogDisplayNameFormatter.brandName(from: source.brandName)
        self.perfumeName = CatalogDisplayNameFormatter.perfumeName(from: source.perfumeName)
        self.genderProfile = Self.genderProfile(from: source.gender)
        self.releaseYear = source.releaseYear
        self.perfumer = source.perfumers.isEmpty ? nil : source.perfumers.joined(separator: ", ")
        self.topNotes = source.topNotes.map(CatalogDisplayNameFormatter.noteName(from:))
        self.middleNotes = source.middleNotes.map(CatalogDisplayNameFormatter.noteName(from:))
        self.baseNotes = source.baseNotes.map(CatalogDisplayNameFormatter.noteName(from:))
        self.accords = source.canonicalAccords
        self.longevityScore = nil
        self.sillageScore = nil
        self.marketSegment = "unclassified"
    }

    private static func genderProfile(from value: String) -> String {
        switch normalized(value) {
        case "men", "man", "male":
            return "masculine"
        case "women", "woman", "female":
            return "feminine"
        default:
            return "unisex"
        }
    }
}

enum CatalogPreparedPerfumeError: Error, Equatable {
    case incompleteMatchingProfile
}

private enum CatalogDisplayNameFormatter {
    static func brandName(from sourceValue: String) -> String {
        let key = normalized(sourceValue)
        if let canonicalName = knownBrandNames[key] {
            return canonicalName
        }
        return titleCaseSlug(sourceValue)
    }

    static func perfumeName(from sourceValue: String) -> String {
        titleCaseSlug(sourceValue)
    }

    static func noteName(from sourceValue: String) -> String {
        titleCaseSlug(sourceValue)
    }

    private static func titleCaseSlug(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .map { $0.lowercased().capitalized }
            .joined(separator: " ")
    }

    private static let knownBrandNames: [String: String] = [
        "by kilian": "Kilian Paris",
        "dolce gabbana": "Dolce & Gabbana",
        "initio parfums prives": "Initio",
        "maison francis kurkdjian": "Maison Francis Kurkdjian",
        "maison martin margiela": "Maison Margiela",
        "yves saint laurent": "Yves Saint Laurent"
    ]
}

enum CatalogNoteNameNormalizer {
    static func russianName(for sourceName: String) -> String? {
        russianNames[normalized(sourceName)]
    }

    private static let russianNames: [String: String] = [
        "agarwood oud": "Уд",
        "amber": "Амбра",
        "ambroxan": "Амброксан",
        "apple": "Яблоко",
        "bergamot": "Бергамот",
        "cardamom": "Кардамон",
        "cedar": "Кедр",
        "coffee": "Кофе",
        "coconut": "Кокос",
        "fig": "Инжир",
        "grapefruit": "Грейпфрут",
        "incense": "Ладан",
        "iris": "Ирис",
        "jasmine": "Жасмин",
        "labdanum": "Лабданум",
        "lavender": "Лаванда",
        "leather": "Кожа",
        "lemon": "Лимон",
        "marine notes": "Морские ноты",
        "mint": "Мята",
        "musk": "Мускус",
        "neroli": "Нероли",
        "nutmeg": "Мускатный орех",
        "orange blossom": "Апельсиновый цвет",
        "oud": "Уд",
        "patchouli": "Пачули",
        "pear": "Груша",
        "pepper": "Перец",
        "pink pepper": "Розовый перец",
        "rose": "Роза",
        "rosewood": "Палисандр",
        "rum": "Ром",
        "saffron": "Шафран",
        "sandalwood": "Сандал",
        "tea": "Чай",
        "tonka bean": "Бобы тонка",
        "vanilla": "Ваниль",
        "vetiver": "Ветивер"
    ]
}

func normalized(_ value: String) -> String {
    value
        .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        .replacingOccurrences(of: "-", with: " ")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
}
