import Fluent
import Foundation
import Vapor

struct PersonalPerfumesRequest: Content {
    let sun: ZodiacSign
    let moon: ZodiacSign
    let ascendant: ZodiacSign
    let elementBalance: ElementBalance

    func validateElementBalance() throws {
        let values = [
            elementBalance.fire,
            elementBalance.earth,
            elementBalance.air,
            elementBalance.water
        ]

        guard values.allSatisfy({ (0...100).contains($0) }) else {
            throw Abort(
                .badRequest,
                reason: "elementBalance values must be in 0...100"
            )
        }

        guard values.reduce(0, +) == 100 else {
            throw Abort(
                .badRequest,
                reason: "elementBalance total must equal 100"
            )
        }
    }
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
            .group(.or) { group in
                for segment in PersonalPerfumeMarketSegment.allCases {
                    group.filter(\.$marketSegment == segment.rawValue)
                }
            }
            .with(\.$brand)
            .with(\.$notes) { query in
                query.with(\.$note)
            }
            .with(\.$accords) { query in
                query.with(\.$accord)
            }
            .all()

        return PersonalPerfumeScorer.score(
            request: request,
            perfumeProfiles: perfumeModels.compactMap(PerfumeProfile.init(model:))
        )
    }
}

enum PersonalPerfumeScorer {
    static func score(
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

private struct WeightedScore {
    let value: Double
    let weight: Double
}

private enum PersonalPerfumeScoreWeight {
    static let accords = 0.35
    static let notes = 0.30
    static let descriptors = 0.25
    static let wear = 0.10
    static let minimumAvailableMetadata = 0.35
}

private struct PersonalPerfumePreference {
    let accordWeights: [String: Double]
    let noteWeights: [String: Double]
    let noteDisplayNames: [String: String]
    let fragranceTokenWeights: [String: Double]
    let moodTokenWeights: [String: Double]
    let styleTokenWeights: [String: Double]
    let targetLongevityScore: Double
    let targetSillageScore: Double

    init(request: PersonalPerfumesRequest) {
        var accordWeights: [String: Double] = [:]
        var noteWeights: [String: Double] = [:]
        var noteDisplayNames: [String: String] = [:]
        var fragranceTokenWeights: [String: Double] = [:]
        var moodTokenWeights: [String: Double] = [:]
        var styleTokenWeights: [String: Double] = [:]
        var longevityValues: [WeightedScore] = []
        var sillageValues: [WeightedScore] = []

        let sunPreference = SignPerfumePreference.preference(for: request.sun)
        Self.add(
            signPreference: sunPreference,
            accordMultiplier: 1.0,
            noteWeight: 3,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        Self.addTokens(sunPreference.fragranceTokens, weight: 1, to: &fragranceTokenWeights)
        longevityValues.append(WeightedScore(value: sunPreference.longevityScore, weight: 1))

        let moonPreference = SignPerfumePreference.preference(for: request.moon)
        Self.add(
            signPreference: moonPreference,
            accordMultiplier: 0.8,
            noteWeight: 2,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        Self.addTokens(moonPreference.moodTokens, weight: 1, to: &moodTokenWeights)
        longevityValues.append(WeightedScore(value: moonPreference.longevityScore, weight: 0.8))

        let ascendantPreference = SignPerfumePreference.preference(for: request.ascendant)
        Self.add(
            signPreference: ascendantPreference,
            accordMultiplier: 0.7,
            noteWeight: 1,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames
        )
        Self.addTokens(ascendantPreference.styleTokens, weight: 1, to: &styleTokenWeights)
        sillageValues.append(WeightedScore(value: ascendantPreference.sillageScore, weight: 1))

        Self.add(
            elementPreference: .fire,
            balance: request.elementBalance.fire,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokenWeights: &fragranceTokenWeights,
            moodTokenWeights: &moodTokenWeights,
            styleTokenWeights: &styleTokenWeights,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .earth,
            balance: request.elementBalance.earth,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokenWeights: &fragranceTokenWeights,
            moodTokenWeights: &moodTokenWeights,
            styleTokenWeights: &styleTokenWeights,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .air,
            balance: request.elementBalance.air,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokenWeights: &fragranceTokenWeights,
            moodTokenWeights: &moodTokenWeights,
            styleTokenWeights: &styleTokenWeights,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )
        Self.add(
            elementPreference: .water,
            balance: request.elementBalance.water,
            accordWeights: &accordWeights,
            noteWeights: &noteWeights,
            noteDisplayNames: &noteDisplayNames,
            fragranceTokenWeights: &fragranceTokenWeights,
            moodTokenWeights: &moodTokenWeights,
            styleTokenWeights: &styleTokenWeights,
            longevityValues: &longevityValues,
            sillageValues: &sillageValues
        )

        self.accordWeights = accordWeights
        self.noteWeights = noteWeights
        self.noteDisplayNames = noteDisplayNames
        self.fragranceTokenWeights = fragranceTokenWeights
        self.moodTokenWeights = moodTokenWeights
        self.styleTokenWeights = styleTokenWeights
        self.targetLongevityScore = Self.weightedAverage(values: longevityValues) ?? 6
        self.targetSillageScore = Self.weightedAverage(values: sillageValues) ?? 6
    }
}

extension PersonalPerfumeScorer {
    fileprivate static func makeScoredPerfume(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> ScoredPersonalPerfume? {
        guard
            let marketSegment = perfumeProfile.marketSegment.flatMap(PersonalPerfumeMarketSegment.init(rawValue:))
        else {
            return nil
        }

        let candidateNoteWeights = noteWeights(for: perfumeProfile)
        guard
            let rawScore = compatibilityScore(
                perfumeProfile: perfumeProfile,
                candidateNoteWeights: candidateNoteWeights,
                preference: preference
            )
        else {
            return nil
        }

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

    fileprivate static func compatibilityScore(
        perfumeProfile: PerfumeProfile,
        candidateNoteWeights: [String: Double],
        preference: PersonalPerfumePreference
    ) -> Double? {
        let scoreComponents: [WeightedScore?] = [
            scoreComponent(
                value: weightedSimilarity(
                    targetWeights: preference.accordWeights,
                    candidateWeights: perfumeProfile.accordWeights
                ),
                weight: PersonalPerfumeScoreWeight.accords,
                isAvailable: !perfumeProfile.accordWeights.isEmpty
            ),
            scoreComponent(
                value: weightedSimilarity(
                    targetWeights: preference.noteWeights,
                    candidateWeights: candidateNoteWeights
                ),
                weight: PersonalPerfumeScoreWeight.notes,
                isAvailable: !candidateNoteWeights.isEmpty
            ),
            descriptorScoreComponent(
                perfumeProfile: perfumeProfile,
                preference: preference
            ),
            wearScoreComponent(
                perfumeProfile: perfumeProfile,
                preference: preference
            )
        ]

        return normalizedScore(
            components: scoreComponents.compactMap { $0 },
            minimumAvailableWeight: PersonalPerfumeScoreWeight.minimumAvailableMetadata
        )
    }

    fileprivate static func scoreComponent(
        value: Double,
        weight: Double,
        isAvailable: Bool
    ) -> WeightedScore? {
        guard isAvailable else {
            return nil
        }

        return WeightedScore(value: value, weight: weight)
    }

    fileprivate static func descriptorScoreComponent(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> WeightedScore? {
        let descriptorComponents: [WeightedScore?] = [
            weightedTokenScore(
                value: perfumeProfile.fragranceFamily,
                targetWeights: preference.fragranceTokenWeights,
                weight: 0.4
            ),
            weightedTokenScore(
                value: perfumeProfile.moodProfile,
                targetWeights: preference.moodTokenWeights,
                weight: 0.35
            ),
            weightedTokenScore(
                value: perfumeProfile.styleProfile,
                targetWeights: preference.styleTokenWeights,
                weight: 0.25
            )
        ]

        guard let descriptorScore = normalizedScore(
            components: descriptorComponents.compactMap { $0 }
        ) else {
            return nil
        }

        return WeightedScore(
            value: descriptorScore,
            weight: PersonalPerfumeScoreWeight.descriptors
        )
    }

    fileprivate static func wearScoreComponent(
        perfumeProfile: PerfumeProfile,
        preference: PersonalPerfumePreference
    ) -> WeightedScore? {
        let wearComponents: [WeightedScore?] = [
            scoreComponent(
                value: scoreSimilarity(
                    value: perfumeProfile.longevityScore,
                    targetValue: preference.targetLongevityScore
                ),
                weight: 0.5,
                isAvailable: perfumeProfile.longevityScore != nil
            ),
            scoreComponent(
                value: scoreSimilarity(
                    value: perfumeProfile.sillageScore,
                    targetValue: preference.targetSillageScore
                ),
                weight: 0.5,
                isAvailable: perfumeProfile.sillageScore != nil
            )
        ]

        guard let wearScore = normalizedScore(
            components: wearComponents.compactMap { $0 }
        ) else {
            return nil
        }

        return WeightedScore(
            value: wearScore,
            weight: PersonalPerfumeScoreWeight.wear
        )
    }

    fileprivate static func weightedTokenScore(
        value: String?,
        targetWeights: [String: Double],
        weight: Double
    ) -> WeightedScore? {
        guard let candidateWeights = tokenWeights(from: value) else {
            return nil
        }

        return WeightedScore(
            value: weightedSimilarity(
                targetWeights: targetWeights,
                candidateWeights: candidateWeights
            ),
            weight: weight
        )
    }

    fileprivate static func normalizedScore(
        components: [WeightedScore],
        minimumAvailableWeight: Double = 0
    ) -> Double? {
        let availableWeight = components.reduce(0) { partialResult, component in
            partialResult + component.weight
        }

        guard availableWeight >= minimumAvailableWeight, availableWeight > 0 else {
            return nil
        }

        let weightedScore = components.reduce(0) { partialResult, component in
            partialResult + component.value * component.weight
        }

        return weightedScore / availableWeight
    }

    fileprivate static func scoreSimilarity(
        value: Int?,
        targetValue: Double
    ) -> Double {
        guard let value else {
            return 0
        }

        let distance = abs(Double(value) - targetValue)
        return max(0, 1 - (distance / 9))
    }

    fileprivate static func matchingNotes(
        preference: PersonalPerfumePreference,
        candidateNoteWeights: [String: Double]
    ) -> [String] {
        preference.noteWeights.keys
            .compactMap { normalizedNote -> (String, Double)? in
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

    fileprivate static func matchingAccords(
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

    fileprivate static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    fileprivate static func tokenWeights(from value: String?) -> [String: Double]? {
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

        return tokens.reduce(into: [:]) { weights, token in
            weights[token, default: 0] += 1
        }
    }

    fileprivate static func areSortedForRecommendationRanking(
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

    fileprivate static func noteWeights(for perfumeProfile: PerfumeProfile) -> [String: Double] {
        var noteWeights: [String: Double] = [:]
        addNotes(perfumeProfile.topNotes, weight: 3, to: &noteWeights)
        addNotes(perfumeProfile.middleNotes, weight: 2, to: &noteWeights)
        addNotes(perfumeProfile.baseNotes, weight: 1, to: &noteWeights)
        return noteWeights
    }

    fileprivate static func addNotes(
        _ notes: [String],
        weight: Double,
        to noteWeights: inout [String: Double]
    ) {
        for note in notes {
            noteWeights[normalize(note), default: 0] += weight
        }
    }

    fileprivate static func weightedSimilarity(
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

}

extension PersonalPerfumePreference {
    fileprivate static func weightedAverage(values: [WeightedScore]) -> Double? {
        let totalWeight = values.reduce(0) { partialResult, score in
            partialResult + score.weight
        }
        guard totalWeight > 0 else {
            return nil
        }

        let weightedTotal = values.reduce(0) { partialResult, score in
            partialResult + score.value * score.weight
        }
        return weightedTotal / totalWeight
    }

    fileprivate static func add(
        signPreference: SignPerfumePreference,
        accordMultiplier: Double,
        noteWeight: Double,
        accordWeights: inout [String: Double],
        noteWeights: inout [String: Double],
        noteDisplayNames: inout [String: String]
    ) {
        for accord in signPreference.accords {
            accordWeights[accord, default: 0] += accordMultiplier
        }

        for note in signPreference.notes {
            let normalizedNote = PersonalPerfumeScorer.normalize(note)
            noteWeights[normalizedNote, default: 0] += noteWeight
            noteDisplayNames[normalizedNote] = note
        }
    }

    fileprivate static func addTokens(
        _ tokens: [String],
        weight: Double,
        to tokenWeights: inout [String: Double]
    ) {
        for token in tokens {
            tokenWeights[PersonalPerfumeScorer.normalize(token), default: 0] += weight
        }
    }

    fileprivate static func add(
        elementPreference: ElementPerfumePreference,
        balance: Int,
        accordWeights: inout [String: Double],
        noteWeights: inout [String: Double],
        noteDisplayNames: inout [String: String],
        fragranceTokenWeights: inout [String: Double],
        moodTokenWeights: inout [String: Double],
        styleTokenWeights: inout [String: Double],
        longevityValues: inout [WeightedScore],
        sillageValues: inout [WeightedScore]
    ) {
        guard balance > 0 else {
            return
        }

        let multiplier = Double(balance) / 100
        for accord in elementPreference.accords {
            accordWeights[accord, default: 0] += multiplier
        }

        let noteWeight = multiplier * 3
        for note in elementPreference.notes {
            let normalizedNote = PersonalPerfumeScorer.normalize(note)
            noteWeights[normalizedNote, default: 0] += noteWeight
            noteDisplayNames[normalizedNote] = note
        }

        addTokens(elementPreference.fragranceTokens, weight: multiplier, to: &fragranceTokenWeights)
        addTokens(elementPreference.moodTokens, weight: multiplier, to: &moodTokenWeights)
        addTokens(elementPreference.styleTokens, weight: multiplier, to: &styleTokenWeights)
        longevityValues.append(WeightedScore(value: elementPreference.longevityScore, weight: multiplier))
        sillageValues.append(WeightedScore(value: elementPreference.sillageScore, weight: multiplier))
    }
}

extension Array where Element == ScoredPersonalPerfume {
    fileprivate func uniqueBySignature() -> [ScoredPersonalPerfume] {
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
