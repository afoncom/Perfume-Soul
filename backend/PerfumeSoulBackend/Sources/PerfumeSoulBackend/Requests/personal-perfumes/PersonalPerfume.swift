import Fluent
import Foundation
import Vapor

struct PersonalPerfumesRequest: Content {
    let sun: ZodiacSign
    let moon: ZodiacSign
    let ascendant: ZodiacSign
    let elementBalance: ElementBalance
}

struct PersonalPerfumeResponse: Codable, Equatable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let marketSegment: PersonalPerfumeMarketSegment
    let matchingNotes: [String]
    let matchingAccords: [String]
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
}

enum PersonalPerfumeMarketSegment: String, Codable, CaseIterable {
    case luxury
    case daily
    case niche
}

enum PersonalPerfumeLoader {
    static func load(
        request: PersonalPerfumesRequest,
        on database: any Database
    ) async throws -> [PersonalPerfumeResponse] {
        let perfumeModels = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .with(\.$notes) { query in
                query.with(\.$note)
            }
            .with(\.$accords) { query in
                query.with(\.$accord)
            }
            .all()

        return load(
            request: request,
            perfumeProfiles: perfumeModels.compactMap(PerfumeProfile.init(model:))
        )
    }

    static func load(
        request: PersonalPerfumesRequest,
        perfumeProfiles: [PerfumeProfile]
    ) -> [PersonalPerfumeResponse] {
        let preference = PersonalPerfumePreference(request: request)
        let scoredPerfumes = perfumeProfiles.compactMap { perfumeProfile in
            makeScoredPerfume(
                perfumeProfile: perfumeProfile,
                preference: preference
            )
        }

        return PersonalPerfumeMarketSegment.allCases.flatMap { segment in
            scoredPerfumes
                .filter { $0.response.marketSegment == segment }
                .sorted(by: areSortedForRecommendationRanking)
                .uniqueBySignature()
                .prefix(3)
                .map(\.response)
        }
    }
}

private struct ScoredPersonalPerfume {
    let response: PersonalPerfumeResponse
    let rawScore: Double
    let signature: String
}

private struct PersonalPerfumePreference {
    let accordWeights: [String: Double]
    let noteWeights: [String: Int]
    let noteDisplayNames: [String: String]
    let fragranceProfile: String
    let moodProfile: String
    let styleProfile: String
    let targetLongevityScore: Double
    let targetSillageScore: Double

    init(request: PersonalPerfumesRequest) {
        var accordWeights: [String: Double] = [:]
        var noteWeights: [String: Int] = [:]
        var noteDisplayNames: [String: String] = [:]
        var fragranceTokens: [String] = []
        var moodTokens: [String] = []
        var styleTokens: [String] = []
        var longevityValues: [Double] = []
        var sillageValues: [Double] = []

        let sunPreference = SignPerfumePreference.preference(for: request.sun)
        Self.add(
            signPreference: sunPreference,
            accordMultiplier: 1.0,
            noteWeight: 3,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        fragranceTokens.append(contentsOf: sunPreference.fragranceTokens)
        longevityValues.append(sunPreference.longevityScore)

        let moonPreference = SignPerfumePreference.preference(for: request.moon)
        Self.add(
            signPreference: moonPreference,
            accordMultiplier: 0.8,
            noteWeight: 2,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        moodTokens.append(contentsOf: moonPreference.moodTokens)
        longevityValues.append(moonPreference.longevityScore)

        let ascendantPreference = SignPerfumePreference.preference(for: request.ascendant)
        Self.add(
            signPreference: ascendantPreference,
            accordMultiplier: 0.7,
            noteWeight: 1,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        styleTokens.append(contentsOf: ascendantPreference.styleTokens)
        sillageValues.append(ascendantPreference.sillageScore)

        Self.add(
            elementPreference: .fire,
            balance: request.elementBalance.fire,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokens: &fragranceTokens,
            moodTokens: &moodTokens,
            styleTokens: &styleTokens,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .earth,
            balance: request.elementBalance.earth,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokens: &fragranceTokens,
            moodTokens: &moodTokens,
            styleTokens: &styleTokens,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .air,
            balance: request.elementBalance.air,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokens: &fragranceTokens,
            moodTokens: &moodTokens,
            styleTokens: &styleTokens,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .water,
            balance: request.elementBalance.water,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokens: &fragranceTokens,
            moodTokens: &moodTokens,
            styleTokens: &styleTokens,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )

        self.accordWeights = accordWeights
        self.noteWeights = noteWeights
        self.noteDisplayNames = noteDisplayNames
        self.fragranceProfile = fragranceTokens.joined(separator: " ")
        self.moodProfile = moodTokens.joined(separator: " ")
        self.styleProfile = styleTokens.joined(separator: " ")
        self.targetLongevityScore = Self.average(values: longevityValues) ?? 6
        self.targetSillageScore = Self.average(values: sillageValues) ?? 6
    }
}

private extension PersonalPerfumeLoader {
    static func makeScoredPerfume(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> ScoredPersonalPerfume? {
        guard
            let marketSegment = perfumeProfile.marketSegment.flatMap(PersonalPerfumeMarketSegment.init(rawValue:))
        else {
            return nil
        }

        let candidateNoteWeights = noteWeights(for: perfumeProfile)
        let notesMatch = weightedSimilarity(
            targetWeights: preference.noteWeights,
            candidateWeights: candidateNoteWeights
        )
        let accordsMatch = weightedSimilarity(
            targetWeights: preference.accordWeights,
            candidateWeights: perfumeProfile.accordWeights
        )
        let familyMoodStyleMatch = descriptorMatch(
            perfumeProfile: perfumeProfile,
            preference: preference
        )
        let longevitySillageMatch = wearMatch(
            perfumeProfile: perfumeProfile,
            preference: preference
        )
        let rawScore =
            accordsMatch * 0.35
            + notesMatch * 0.30
            + familyMoodStyleMatch * 0.25
            + longevitySillageMatch * 0.10
        let matchPercentage = min(
            100,
            max(0, Int((rawScore * 100).rounded(.toNearestOrAwayFromZero)))
        )

        return ScoredPersonalPerfume(
            response: PersonalPerfumeResponse(
                id: perfumeProfile.id,
                perfumeName: perfumeProfile.perfumeName,
                brandName: perfumeProfile.brandName,
                marketSegment: marketSegment,
                matchingNotes: matchingNotes(
                    preference: preference,
                    candidateNoteWeights: candidateNoteWeights
                ),
                matchingAccords: matchingAccords(
                    preference: preference,
                    candidateAccordWeights: perfumeProfile.accordWeights
                ),
                matchPercentage: matchPercentage,
                longevityScore: perfumeProfile.longevityScore,
                sillageScore: perfumeProfile.sillageScore
            ),
            rawScore: rawScore,
            signature: perfumeProfile.signature
        )
    }

    static func areSortedForRecommendationRanking(
        lhs: ScoredPersonalPerfume,
        rhs: ScoredPersonalPerfume
    ) -> Bool {
        if lhs.rawScore == rhs.rawScore {
            if lhs.response.brandName == rhs.response.brandName {
                if lhs.response.perfumeName == rhs.response.perfumeName {
                    return lhs.response.id < rhs.response.id
                }

                return lhs.response.perfumeName < rhs.response.perfumeName
            }

            return lhs.response.brandName < rhs.response.brandName
        }

        return lhs.rawScore > rhs.rawScore
    }

    static func noteWeights(for perfumeProfile: PerfumeProfile) -> [String: Int] {
        var noteWeights: [String: Int] = [:]
        addNotes(perfumeProfile.topNotes, weight: 3, to: &noteWeights)
        addNotes(perfumeProfile.middleNotes, weight: 2, to: &noteWeights)
        addNotes(perfumeProfile.baseNotes, weight: 1, to: &noteWeights)
        return noteWeights
    }

    static func addNotes(
        _ notes: [String],
        weight: Int,
        to noteWeights: inout [String: Int]
    ) {
        for note in notes {
            noteWeights[normalize(note), default: 0] += weight
        }
    }

    static func weightedSimilarity(
        targetWeights: [String: Int],
        candidateWeights: [String: Int]
    ) -> Double {
        guard !targetWeights.isEmpty, !candidateWeights.isEmpty else {
            return 0
        }

        let overlapWeight = Set(targetWeights.keys).intersection(candidateWeights.keys).reduce(0) { partialResult, key in
            partialResult + min(targetWeights[key] ?? 0, candidateWeights[key] ?? 0)
        }
        let coverage = Double(overlapWeight) / Double(targetWeights.values.reduce(0, +))
        let precision = Double(overlapWeight) / Double(candidateWeights.values.reduce(0, +))
        return coverage * 0.7 + precision * 0.3
    }

    static func weightedSimilarity(
        targetWeights: [String: Double],
        candidateWeights: [String: Double]
    ) -> Double {
        guard !targetWeights.isEmpty, !candidateWeights.isEmpty else {
            return 0
        }

        let overlapWeight = Set(targetWeights.keys).intersection(candidateWeights.keys).reduce(0.0) { partialResult, key in
            partialResult + min(targetWeights[key] ?? 0, candidateWeights[key] ?? 0)
        }
        let coverage = overlapWeight / targetWeights.values.reduce(0, +)
        let precision = overlapWeight / candidateWeights.values.reduce(0, +)
        return coverage * 0.7 + precision * 0.3
    }

    static func descriptorMatch(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> Double {
        let familyScore = stringSimilarity(
            value: perfumeProfile.fragranceFamily,
            targetValue: preference.fragranceProfile
        )
        let moodScore = stringSimilarity(
            value: perfumeProfile.moodProfile,
            targetValue: preference.moodProfile
        )
        let styleScore = stringSimilarity(
            value: perfumeProfile.styleProfile,
            targetValue: preference.styleProfile
        )
        return familyScore * 0.4 + moodScore * 0.35 + styleScore * 0.25
    }

    static func wearMatch(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> Double {
        let longevitySimilarity = scoreSimilarity(
            value: perfumeProfile.longevityScore,
            targetValue: preference.targetLongevityScore
        )
        let sillageSimilarity = scoreSimilarity(
            value: perfumeProfile.sillageScore,
            targetValue: preference.targetSillageScore
        )
        return longevitySimilarity * 0.5 + sillageSimilarity * 0.5
    }

    static func scoreSimilarity(
        value: Int?,
        targetValue: Double
    ) -> Double {
        guard let value else {
            return 0
        }

        let distance = abs(Double(value) - targetValue)
        return max(0, 1 - (distance / 9))
    }

    static func stringSimilarity(
        value: String?,
        targetValue: String
    ) -> Double {
        guard
            let valueTokens = normalizedTokens(from: value),
            let targetTokens = normalizedTokens(from: targetValue)
        else {
            return 0
        }

        let overlapCount = valueTokens.intersection(targetTokens).count
        guard overlapCount > 0 else {
            return 0
        }

        let coverage = Double(overlapCount) / Double(targetTokens.count)
        let precision = Double(overlapCount) / Double(valueTokens.count)
        return coverage * 0.7 + precision * 0.3
    }

    static func matchingNotes(
        preference: PersonalPerfumePreference,
        candidateNoteWeights: [String: Int]
    ) -> [String] {
        preference.noteWeights.keys
            .compactMap { normalizedNote -> (String, Int)? in
                guard let candidateWeight = candidateNoteWeights[normalizedNote] else {
                    return nil
                }

                let overlapWeight = min(preference.noteWeights[normalizedNote] ?? 0, candidateWeight)
                guard let displayName = preference.noteDisplayNames[normalizedNote] else {
                    return nil
                }

                return (displayName, overlapWeight)
            }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0 < rhs.0
                }

                return lhs.1 > rhs.1
            }
            .prefix(5)
            .map(\.0)
    }

    static func matchingAccords(
        preference: PersonalPerfumePreference,
        candidateAccordWeights: [String: Double]
    ) -> [String] {
        preference.accordWeights.keys
            .compactMap { accord -> (String, Double)? in
                guard let candidateWeight = candidateAccordWeights[accord] else {
                    return nil
                }

                return (accord, min(preference.accordWeights[accord] ?? 0, candidateWeight))
            }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0 < rhs.0
                }

                return lhs.1 > rhs.1
            }
            .prefix(5)
            .map(\.0)
    }

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    static func normalizedTokens(from value: String?) -> Set<String>? {
        guard let value else {
            return nil
        }

        let tokens = value
            .split(separator: " ")
            .map(String.init)
            .map(normalize)
            .filter { !$0.isEmpty }

        guard !tokens.isEmpty else {
            return nil
        }

        return Set(tokens)
    }
}

private extension PersonalPerfumePreference {
    static func average(values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) / Double(values.count)
    }

    static func add(
        signPreference: SignPerfumePreference,
        accordMultiplier: Double,
        noteWeight: Int,
        accordWeights: inout [String: Double],
        noteWeights: inout [String: Int],
        noteDisplayNames: inout [String: String]
    ) {
        for accord in signPreference.accords {
            accordWeights[accord, default: 0] += accordMultiplier
        }

        for note in signPreference.notes {
            let normalizedNote = PersonalPerfumeLoader.normalize(note)
            noteWeights[normalizedNote, default: 0] += noteWeight
            noteDisplayNames[normalizedNote] = note
        }
    }

    static func add(
        elementPreference: ElementPerfumePreference,
        balance: Int,
        accordWeights: inout [String: Double],
        noteWeights: inout [String: Int],
        noteDisplayNames: inout [String: String],
        fragranceTokens: inout [String],
        moodTokens: inout [String],
        styleTokens: inout [String],
        longevityValues: inout [Double],
        sillageValues: inout [Double]
    ) {
        guard balance > 0 else {
            return
        }

        let multiplier = Double(balance) / 100
        for accord in elementPreference.accords {
            accordWeights[accord, default: 0] += multiplier
        }

        let noteWeight = max(1, Int((multiplier * 3).rounded(.toNearestOrAwayFromZero)))
        for note in elementPreference.notes {
            let normalizedNote = PersonalPerfumeLoader.normalize(note)
            noteWeights[normalizedNote, default: 0] += noteWeight
            noteDisplayNames[normalizedNote] = note
        }

        fragranceTokens.append(contentsOf: elementPreference.fragranceTokens)
        moodTokens.append(contentsOf: elementPreference.moodTokens)
        styleTokens.append(contentsOf: elementPreference.styleTokens)
        longevityValues.append(elementPreference.longevityScore)
        sillageValues.append(elementPreference.sillageScore)
    }
}

private extension Array where Element == ScoredPersonalPerfume {
    func uniqueBySignature() -> [ScoredPersonalPerfume] {
        var seenSignatures = Set<String>()
        var uniquePerfumes: [ScoredPersonalPerfume] = []

        for perfume in self where seenSignatures.insert(perfume.signature).inserted {
            uniquePerfumes.append(perfume)
        }

        return uniquePerfumes
    }
}

private struct SignPerfumePreference {
    let accords: [String]
    let notes: [String]
    let fragranceTokens: [String]
    let moodTokens: [String]
    let styleTokens: [String]
    let longevityScore: Double
    let sillageScore: Double

    static func preference(for sign: ZodiacSign) -> SignPerfumePreference {
        switch sign {
        case .aries:
            SignPerfumePreference(
                accords: ["spicy", "citrus", "leather", "woody"],
                notes: ["Перец", "Имбирь", "Бергамот", "Кожа"],
                fragranceTokens: ["woody", "spicy", "citrus"],
                moodTokens: ["energetic", "bold"],
                styleTokens: ["bold", "sporty", "modern"],
                longevityScore: 7,
                sillageScore: 8
            )
        case .taurus:
            SignPerfumePreference(
                accords: ["woody", "green", "floral", "gourmand"],
                notes: ["Ветивер", "Пачули", "Роза", "Ваниль"],
                fragranceTokens: ["woody", "floral", "green"],
                moodTokens: ["cozy", "grounded", "soft"],
                styleTokens: ["elegant", "refined", "sensual"],
                longevityScore: 8,
                sillageScore: 6
            )
        case .gemini:
            SignPerfumePreference(
                accords: ["fresh", "citrus", "aromatic", "green"],
                notes: ["Лимон", "Бергамот", "Мята", "Лаванда"],
                fragranceTokens: ["fresh", "citrus", "aromatic"],
                moodTokens: ["airy", "bright", "energetic"],
                styleTokens: ["clean", "versatile", "modern"],
                longevityScore: 5,
                sillageScore: 5
            )
        case .cancer:
            SignPerfumePreference(
                accords: ["marine", "floral", "musky", "powdery"],
                notes: ["Морские ноты", "Жасмин", "Мускус", "Ирис"],
                fragranceTokens: ["marine", "fresh", "floral"],
                moodTokens: ["romantic", "soft", "intimate"],
                styleTokens: ["clean", "romantic", "gentle"],
                longevityScore: 6,
                sillageScore: 5
            )
        case .leo:
            SignPerfumePreference(
                accords: ["amber", "spicy", "gourmand", "citrus"],
                notes: ["Шафран", "Амбра", "Ваниль", "Апельсиновый цвет"],
                fragranceTokens: ["amber", "spicy", "gourmand"],
                moodTokens: ["warm", "indulgent", "sensual"],
                styleTokens: ["glamorous", "bold", "luxe"],
                longevityScore: 8,
                sillageScore: 9
            )
        case .virgo:
            SignPerfumePreference(
                accords: ["green", "woody", "fresh", "musky"],
                notes: ["Ветивер", "Мускус", "Чай", "Лаванда"],
                fragranceTokens: ["fresh", "woody", "green"],
                moodTokens: ["balanced", "clean", "grounded"],
                styleTokens: ["minimal", "clean", "refined"],
                longevityScore: 6,
                sillageScore: 4
            )
        case .libra:
            SignPerfumePreference(
                accords: ["floral", "musky", "powdery", "fresh"],
                notes: ["Роза", "Ирис", "Мускус", "Бергамот"],
                fragranceTokens: ["floral", "fresh", "powdery"],
                moodTokens: ["romantic", "soft", "balanced"],
                styleTokens: ["elegant", "romantic", "classic"],
                longevityScore: 6,
                sillageScore: 6
            )
        case .scorpio:
            SignPerfumePreference(
                accords: ["amber", "smoky", "leather", "woody"],
                notes: ["Уд", "Ладан", "Кожа", "Пачули"],
                fragranceTokens: ["amber", "woody", "leather"],
                moodTokens: ["dark", "sensual", "intense"],
                styleTokens: ["dark", "bold", "sensual"],
                longevityScore: 9,
                sillageScore: 8
            )
        case .sagittarius:
            SignPerfumePreference(
                accords: ["citrus", "aromatic", "spicy", "woody"],
                notes: ["Грейпфрут", "Кардамон", "Можжевельник", "Кедр"],
                fragranceTokens: ["citrus", "aromatic", "woody"],
                moodTokens: ["bright", "energetic", "adventurous"],
                styleTokens: ["casual", "active", "bright"],
                longevityScore: 6,
                sillageScore: 7
            )
        case .capricorn:
            SignPerfumePreference(
                accords: ["woody", "earthy", "leather", "aromatic"],
                notes: ["Кедр", "Ветивер", "Пачули", "Кожа"],
                fragranceTokens: ["woody", "earthy", "aromatic"],
                moodTokens: ["grounded", "refined", "serious"],
                styleTokens: ["classic", "tailored", "formal"],
                longevityScore: 9,
                sillageScore: 6
            )
        case .aquarius:
            SignPerfumePreference(
                accords: ["fresh", "marine", "musky", "aromatic"],
                notes: ["Морские ноты", "Мята", "Мускус", "Лаванда"],
                fragranceTokens: ["fresh", "marine", "aromatic"],
                moodTokens: ["airy", "clean", "modern"],
                styleTokens: ["modern", "minimal", "unusual"],
                longevityScore: 5,
                sillageScore: 5
            )
        case .pisces:
            SignPerfumePreference(
                accords: ["marine", "floral", "powdery", "gourmand"],
                notes: ["Морские ноты", "Жасмин", "Ваниль", "Ладан"],
                fragranceTokens: ["marine", "floral", "powdery"],
                moodTokens: ["romantic", "dreamy", "soft"],
                styleTokens: ["soft", "romantic", "intimate"],
                longevityScore: 6,
                sillageScore: 5
            )
        }
    }
}

private struct ElementPerfumePreference {
    let accords: [String]
    let notes: [String]
    let fragranceTokens: [String]
    let moodTokens: [String]
    let styleTokens: [String]
    let longevityScore: Double
    let sillageScore: Double

    static let fire = ElementPerfumePreference(
        accords: ["spicy", "amber", "leather", "smoky", "citrus"],
        notes: ["Перец", "Шафран", "Кожа", "Ладан", "Бергамот"],
        fragranceTokens: ["spicy", "amber", "leather", "citrus"],
        moodTokens: ["warm", "energetic", "bold"],
        styleTokens: ["bold", "glamorous", "strong"],
        longevityScore: 7,
        sillageScore: 9
    )
    static let earth = ElementPerfumePreference(
        accords: ["woody", "green", "earthy", "powdery"],
        notes: ["Ветивер", "Пачули", "Ирис", "Кедр", "Сандал"],
        fragranceTokens: ["woody", "green", "earthy"],
        moodTokens: ["grounded", "refined", "balanced"],
        styleTokens: ["elegant", "classic", "refined"],
        longevityScore: 9,
        sillageScore: 6
    )
    static let air = ElementPerfumePreference(
        accords: ["fresh", "citrus", "aromatic", "musky"],
        notes: ["Бергамот", "Лимон", "Лаванда", "Мята", "Мускус"],
        fragranceTokens: ["fresh", "citrus", "aromatic"],
        moodTokens: ["airy", "clean", "bright"],
        styleTokens: ["clean", "modern", "light"],
        longevityScore: 5,
        sillageScore: 5
    )
    static let water = ElementPerfumePreference(
        accords: ["marine", "floral", "musky", "gourmand", "powdery"],
        notes: ["Морские ноты", "Жасмин", "Мускус", "Ваниль", "Ладан", "Ирис"],
        fragranceTokens: ["marine", "floral", "powdery"],
        moodTokens: ["romantic", "soft", "emotional"],
        styleTokens: ["soft", "intimate", "gentle"],
        longevityScore: 6,
        sillageScore: 4
    )
}
