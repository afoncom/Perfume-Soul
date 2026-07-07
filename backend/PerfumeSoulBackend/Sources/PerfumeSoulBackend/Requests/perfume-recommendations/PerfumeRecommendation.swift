import Fluent
import Foundation
import Vapor

struct PerfumeRecommendation: Codable, Equatable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let matchingNotes: [String]
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
}

enum PerfumeRecommendationLoader {
    static func load(
        perfumeIDs: [Int],
        on database: any Database
    ) async throws -> [PerfumeRecommendation] {
        let selectedPerfumeIDs = uniquePerfumeIDs(from: perfumeIDs)
        guard !selectedPerfumeIDs.isEmpty else {
            return []
        }

        let perfumeModels = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .with(\.$notes) { query in
                query.with(\.$note)
            }
            .with(\.$accords) { query in
                query.with(\.$accord)
            }
            .all()

        let perfumeProfiles = perfumeModels.compactMap(PerfumeProfile.init(model:))
        return try load(
            perfumeProfiles: perfumeProfiles,
            selectedPerfumeIDs: selectedPerfumeIDs
        )
    }

    static func load(
        perfumeProfiles: [PerfumeProfile],
        selectedPerfumeIDs: [Int]
    ) throws -> [PerfumeRecommendation] {
        let uniqueSelectedPerfumeIDs = uniquePerfumeIDs(from: selectedPerfumeIDs)
        let selectedPerfumeProfiles = uniqueSelectedPerfumeIDs.compactMap { perfumeID in
            perfumeProfiles.first(where: { $0.id == perfumeID })
        }

        guard selectedPerfumeProfiles.count == uniqueSelectedPerfumeIDs.count else {
            throw Abort(.notFound)
        }

        let targetProfile = RecommendationTargetProfile(perfumeProfiles: selectedPerfumeProfiles)
        let scoreRanges = ScoreRanges(perfumeProfiles: perfumeProfiles)

        return perfumeProfiles
            .filter { !uniqueSelectedPerfumeIDs.contains($0.id) }
            .compactMap { perfumeProfile in
                makeScoredRecommendation(
                    perfumeProfile: perfumeProfile,
                    targetProfile: targetProfile,
                    scoreRanges: scoreRanges
                )
            }
            .sorted(by: areSortedForRecommendationRanking)
            .uniqueBySignature()
            .prefix(5)
            .map(\.recommendation)
    }
}

private struct ScoredPerfumeRecommendation {
    let recommendation: PerfumeRecommendation
    let rawScore: Double
    let signature: String
}

private extension PerfumeRecommendationLoader {
    static func areSortedForRecommendationRanking(
        lhs: ScoredPerfumeRecommendation,
        rhs: ScoredPerfumeRecommendation
    ) -> Bool {
        if lhs.rawScore == rhs.rawScore {
            if lhs.recommendation.brandName == rhs.recommendation.brandName {
                if lhs.recommendation.perfumeName == rhs.recommendation.perfumeName {
                    return lhs.recommendation.id < rhs.recommendation.id
                }

                return lhs.recommendation.perfumeName < rhs.recommendation.perfumeName
            }

            return lhs.recommendation.brandName < rhs.recommendation.brandName
        }

        return lhs.rawScore > rhs.rawScore
    }

    static func uniquePerfumeIDs(from perfumeIDs: [Int]) -> [Int] {
        var seenPerfumeIDs = Set<Int>()
        var uniquePerfumeIDs: [Int] = []

        for perfumeID in perfumeIDs where seenPerfumeIDs.insert(perfumeID).inserted {
            uniquePerfumeIDs.append(perfumeID)
        }

        return Array(uniquePerfumeIDs.prefix(3))
    }

    static func makeScoredRecommendation(
        perfumeProfile: PerfumeProfile,
        targetProfile: RecommendationTargetProfile,
        scoreRanges: ScoreRanges
    ) -> ScoredPerfumeRecommendation? {
        let candidateNoteWeights = noteWeights(for: perfumeProfile)
        let overlapWeight = weightedOverlap(
            lhs: targetProfile.noteWeights,
            rhs: candidateNoteWeights
        )
        let matchedDistinctNotesCount = matchedDistinctNotesCount(
            targetProfile: targetProfile,
            candidateNoteWeights: candidateNoteWeights
        )
        let matchingNotes = makeMatchingNotes(
            targetProfile: targetProfile,
            candidateNoteWeights: candidateNoteWeights
        )

        guard matchedDistinctNotesCount > 0 else {
            return nil
        }

        let noteCoverage = weightedCoverage(
            overlapWeight: overlapWeight,
            totalWeight: targetProfile.totalNoteWeight
        )
        let notePrecision = weightedCoverage(
            overlapWeight: overlapWeight,
            totalWeight: totalWeight(of: candidateNoteWeights)
        )
        let distinctCoverage = distinctCoverage(
            matchedCount: matchedDistinctNotesCount,
            totalCount: targetProfile.distinctNoteCount
        )
        let noteCountCloseness = countCloseness(
            lhs: candidateNoteWeights.count,
            rhs: targetProfile.distinctNoteCount
        )
        let candidateAccordWeights = perfumeProfile.accordWeights
        let accordOverlapWeight = weightedOverlap(
            lhs: targetProfile.accordWeights,
            rhs: candidateAccordWeights
        )
        let accordCoverage = weightedCoverage(
            overlapWeight: accordOverlapWeight,
            totalWeight: targetProfile.totalAccordWeight
        )
        let accordPrecision = weightedCoverage(
            overlapWeight: accordOverlapWeight,
            totalWeight: totalWeight(of: candidateAccordWeights)
        )
        let accordCountCloseness = countCloseness(
            lhs: candidateAccordWeights.count,
            rhs: targetProfile.distinctAccordCount
        )
        let familySimilarity = stringSimilarity(
            value: perfumeProfile.fragranceFamily,
            targetValue: targetProfile.fragranceFamily
        )
        let concentrationSimilarity = stringSimilarity(
            value: perfumeProfile.concentration,
            targetValue: targetProfile.concentration
        )
        let seasonSimilarity = stringSimilarity(
            value: perfumeProfile.seasonProfile,
            targetValue: targetProfile.seasonProfile
        )
        let occasionSimilarity = stringSimilarity(
            value: perfumeProfile.occasionProfile,
            targetValue: targetProfile.occasionProfile
        )
        let styleSimilarity = stringSimilarity(
            value: perfumeProfile.styleProfile,
            targetValue: targetProfile.styleProfile
        )
        let genderSimilarity = stringSimilarity(
            value: perfumeProfile.genderProfile,
            targetValue: targetProfile.genderProfile
        )
        let moodSimilarity = stringSimilarity(
            value: perfumeProfile.moodProfile,
            targetValue: targetProfile.moodProfile
        )
        let longevitySimilarity = scoreSimilarity(
            value: perfumeProfile.longevityScore,
            targetValue: targetProfile.averageLongevityScore,
            scoreRange: scoreRanges.longevity
        )
        let sillageSimilarity = scoreSimilarity(
            value: perfumeProfile.sillageScore,
            targetValue: targetProfile.averageSillageScore,
            scoreRange: scoreRanges.sillage
        )

        let noteScore =
            noteCoverage * 0.7
            + notePrecision * 0.3
        let accordScore =
            accordCoverage * 0.7
            + accordPrecision * 0.3
        let wearScore =
            longevitySimilarity * 0.5
            + sillageSimilarity * 0.5
        let weightedComponents: [(Double, Double)] = [
            (noteScore, 0.27),
            (distinctCoverage, 0.07),
            (noteCountCloseness, 0.03),
            (accordScore, 0.17),
            (accordCountCloseness, 0.03),
            (familySimilarity, 0.07),
            (concentrationSimilarity, 0.04),
            (seasonSimilarity, 0.08),
            (occasionSimilarity, 0.08),
            (styleSimilarity, 0.08),
            (genderSimilarity, 0.07),
            (moodSimilarity, 0.06),
            (wearScore, 0.05)
        ]
        let totalWeight = weightedComponents.reduce(0.0) { partialResult, component in
            partialResult + component.1
        }
        let rawScore = weightedComponents.reduce(0.0) { partialResult, component in
            partialResult + component.0 * component.1
        } / totalWeight
        let matchPercentage = min(
            100,
            max(0, Int((rawScore * 100).rounded(.toNearestOrAwayFromZero)))
        )

        return ScoredPerfumeRecommendation(
            recommendation: PerfumeRecommendation(
                id: perfumeProfile.id,
                perfumeName: perfumeProfile.perfumeName,
                brandName: perfumeProfile.brandName,
                matchingNotes: matchingNotes,
                matchPercentage: matchPercentage,
                longevityScore: perfumeProfile.longevityScore,
                sillageScore: perfumeProfile.sillageScore
            ),
            rawScore: rawScore,
            signature: perfumeProfile.signature
        )
    }

    static func noteWeights(for perfumeProfile: PerfumeProfile) -> [String: Int] {
        var noteWeights: [String: Int] = [:]

        addNotes(
            perfumeProfile.topNotes,
            weight: 3,
            to: &noteWeights
        )
        addNotes(
            perfumeProfile.middleNotes,
            weight: 2,
            to: &noteWeights
        )
        addNotes(
            perfumeProfile.baseNotes,
            weight: 1,
            to: &noteWeights
        )

        return noteWeights
    }

    static func addNotes(
        _ notes: [String],
        weight: Int,
        to noteWeights: inout [String: Int]
    ) {
        for note in notes {
            let normalizedNote = normalize(note)
            noteWeights[normalizedNote, default: 0] += weight
        }
    }

    static func makeMatchingNotes(
        targetProfile: RecommendationTargetProfile,
        candidateNoteWeights: [String: Int]
    ) -> [String] {
        targetProfile.noteWeights.keys
            .compactMap { normalizedNote -> (String, Int)? in
                guard let candidateWeight = candidateNoteWeights[normalizedNote] else {
                    return nil
                }

                guard let displayName = targetProfile.noteDisplayNames[normalizedNote] else {
                    return nil
                }

                let overlapWeight = min(
                    targetProfile.noteWeights[normalizedNote] ?? 0,
                    candidateWeight
                )

                return (displayName, overlapWeight)
            }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0 < rhs.0
                }

                return lhs.1 > rhs.1
            }
            .prefix(5)
            .map { $0.0 }
    }

    static func matchedDistinctNotesCount(
        targetProfile: RecommendationTargetProfile,
        candidateNoteWeights: [String: Int]
    ) -> Int {
        targetProfile.noteWeights.keys.reduce(0) { partialResult, normalizedNote in
            partialResult + (candidateNoteWeights[normalizedNote] == nil ? 0 : 1)
        }
    }

    static func weightedOverlap(
        lhs: [String: Int],
        rhs: [String: Int]
    ) -> Int {
        let allKeys = Set(lhs.keys).union(rhs.keys)
        guard !allKeys.isEmpty else {
            return 0
        }

        return allKeys.reduce(0) { partialResult, key in
            partialResult + min(lhs[key] ?? 0, rhs[key] ?? 0)
        }
    }

    static func weightedOverlap(
        lhs: [String: Double],
        rhs: [String: Double]
    ) -> Double {
        let allKeys = Set(lhs.keys).union(rhs.keys)
        guard !allKeys.isEmpty else {
            return 0
        }

        return allKeys.reduce(0) { partialResult, key in
            partialResult + min(lhs[key] ?? 0, rhs[key] ?? 0)
        }
    }

    static func weightedCoverage(
        overlapWeight: Int,
        totalWeight: Int
    ) -> Double {
        guard totalWeight > 0 else {
            return 0
        }

        return Double(overlapWeight) / Double(totalWeight)
    }

    static func weightedCoverage(
        overlapWeight: Double,
        totalWeight: Double
    ) -> Double {
        guard totalWeight > 0 else {
            return 0
        }

        return overlapWeight / totalWeight
    }

    static func distinctCoverage(
        matchedCount: Int,
        totalCount: Int
    ) -> Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(matchedCount) / Double(totalCount)
    }

    static func countCloseness(
        lhs: Int,
        rhs: Int
    ) -> Double {
        let maxCount = max(lhs, rhs)
        guard maxCount > 0 else {
            return 0
        }

        let distance = abs(lhs - rhs)
        return max(0, 1 - (Double(distance) / Double(maxCount)))
    }

    static func totalWeight(of noteWeights: [String: Int]) -> Int {
        noteWeights.values.reduce(0, +)
    }

    static func totalWeight(of accordWeights: [String: Double]) -> Double {
        accordWeights.values.reduce(0, +)
    }

    static func scoreSimilarity(
        value: Int?,
        targetValue: Double?,
        scoreRange: ClosedRange<Int>?
    ) -> Double {
        guard
            let value,
            let targetValue,
            let scoreRange
        else {
            return 0
        }

        let rangeSpan = Double(scoreRange.upperBound - scoreRange.lowerBound)
        guard rangeSpan > 0 else {
            return 1
        }

        let distance = abs(Double(value) - targetValue)
        return max(0, 1 - (distance / rangeSpan))
    }

    static func stringSimilarity(
        value: String?,
        targetValue: String?
    ) -> Double {
        guard
            let value = normalizedTokens(from: value),
            let targetValue = normalizedTokens(from: targetValue)
        else {
            return 0
        }

        if value == targetValue {
            return 1
        }

        let overlapCount = value.intersection(targetValue).count
        guard overlapCount > 0 else {
            return 0
        }

        let coverage = Double(overlapCount) / Double(targetValue.count)
        let precision = Double(overlapCount) / Double(value.count)
        return coverage * 0.7 + precision * 0.3
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

private extension Array where Element == ScoredPerfumeRecommendation {
    func uniqueBySignature() -> [ScoredPerfumeRecommendation] {
        var seenSignatures = Set<String>()
        var uniqueRecommendations: [ScoredPerfumeRecommendation] = []

        for recommendation in self where seenSignatures.insert(recommendation.signature).inserted {
            uniqueRecommendations.append(recommendation)
        }

        return uniqueRecommendations
    }
}

private struct RecommendationTargetProfile {
    let noteWeights: [String: Int]
    let noteDisplayNames: [String: String]
    let totalNoteWeight: Int
    let distinctNoteCount: Int
    let accordWeights: [String: Double]
    let totalAccordWeight: Double
    let distinctAccordCount: Int
    let fragranceFamily: String?
    let concentration: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let averageLongevityScore: Double?
    let averageSillageScore: Double?

    init(perfumeProfiles: [PerfumeProfile]) {
        var noteWeights: [String: Int] = [:]
        var noteDisplayNames: [String: String] = [:]
        var accordWeights: [String: Double] = [:]

        for perfumeProfile in perfumeProfiles {
            Self.addNotes(
                perfumeProfile.topNotes,
                weight: 3,
                noteWeights: &noteWeights,
                noteDisplayNames: &noteDisplayNames
            )
            Self.addNotes(
                perfumeProfile.middleNotes,
                weight: 2,
                noteWeights: &noteWeights,
                noteDisplayNames: &noteDisplayNames
            )
            Self.addNotes(
                perfumeProfile.baseNotes,
                weight: 1,
                noteWeights: &noteWeights,
                noteDisplayNames: &noteDisplayNames
            )
            Self.addAccords(
                perfumeProfile.accordWeights,
                accordWeights: &accordWeights
            )
        }

        self.noteWeights = noteWeights
        self.noteDisplayNames = noteDisplayNames
        self.totalNoteWeight = noteWeights.values.reduce(0, +)
        self.distinctNoteCount = noteWeights.count
        self.accordWeights = accordWeights
        self.totalAccordWeight = accordWeights.values.reduce(0, +)
        self.distinctAccordCount = accordWeights.count
        self.fragranceFamily = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.fragranceFamily)
        )
        self.concentration = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.concentration)
        )
        self.seasonProfile = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.seasonProfile)
        )
        self.occasionProfile = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.occasionProfile)
        )
        self.styleProfile = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.styleProfile)
        )
        self.genderProfile = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.genderProfile)
        )
        self.moodProfile = Self.makeSharedDescriptor(
            values: perfumeProfiles.compactMap(\.moodProfile)
        )
        self.averageLongevityScore = Self.average(
            values: perfumeProfiles.compactMap(\.longevityScore)
        )
        self.averageSillageScore = Self.average(
            values: perfumeProfiles.compactMap(\.sillageScore)
        )
    }

    private static func addNotes(
        _ notes: [String],
        weight: Int,
        noteWeights: inout [String: Int],
        noteDisplayNames: inout [String: String]
    ) {
        for note in notes {
            let normalizedNote = PerfumeRecommendationLoader.normalize(note)
            noteWeights[normalizedNote, default: 0] += weight
            noteDisplayNames[normalizedNote] = note
        }
    }

    private static func addAccords(
        _ accords: [String: Double],
        accordWeights: inout [String: Double]
    ) {
        for (accord, weight) in accords {
            accordWeights[accord, default: 0] += weight
        }
    }

    private static func average(values: [Int]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        let total = values.reduce(0, +)
        return Double(total) / Double(values.count)
    }

    private static func makeSharedDescriptor(values: [String]) -> String? {
        guard !values.isEmpty else {
            return nil
        }

        return values.joined(separator: " ")
    }
}

private struct ScoreRanges {
    let longevity: ClosedRange<Int>?
    let sillage: ClosedRange<Int>?

    init(perfumeProfiles: [PerfumeProfile]) {
        self.longevity = Self.makeRange(
            values: perfumeProfiles.compactMap(\.longevityScore)
        )
        self.sillage = Self.makeRange(
            values: perfumeProfiles.compactMap(\.sillageScore)
        )
    }

    private static func makeRange(values: [Int]) -> ClosedRange<Int>? {
        guard
            let minValue = values.min(),
            let maxValue = values.max()
        else {
            return nil
        }

        return minValue...maxValue
    }
}

struct PerfumeProfile {
    let id: Int
    let perfumeName: String
    let brandName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
    let accordWeights: [String: Double]
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let signature: String

    init(
        id: Int,
        perfumeName: String,
        brandName: String,
        longevityScore: Int? = nil,
        sillageScore: Int? = nil,
        topNotes: [String] = [],
        middleNotes: [String] = [],
        baseNotes: [String] = [],
        accordWeights: [String: Double] = [:],
        concentration: String? = nil,
        fragranceFamily: String? = nil,
        seasonProfile: String? = nil,
        occasionProfile: String? = nil,
        styleProfile: String? = nil,
        genderProfile: String? = nil,
        moodProfile: String? = nil
    ) {
        self.id = id
        self.perfumeName = perfumeName
        self.brandName = brandName
        self.longevityScore = longevityScore
        self.sillageScore = sillageScore
        self.topNotes = topNotes
        self.middleNotes = middleNotes
        self.baseNotes = baseNotes
        self.accordWeights = accordWeights
        self.concentration = concentration
        self.fragranceFamily = fragranceFamily
        self.seasonProfile = seasonProfile
        self.occasionProfile = occasionProfile
        self.styleProfile = styleProfile
        self.genderProfile = genderProfile
        self.moodProfile = moodProfile
        self.signature = Self.makeSignature(
            topNotes: topNotes,
            middleNotes: middleNotes,
            baseNotes: baseNotes,
            accordWeights: accordWeights,
            concentration: concentration,
            fragranceFamily: fragranceFamily,
            seasonProfile: seasonProfile,
            occasionProfile: occasionProfile,
            styleProfile: styleProfile,
            genderProfile: genderProfile,
            moodProfile: moodProfile,
            longevityScore: longevityScore,
            sillageScore: sillageScore
        )
    }

    init?(model: PerfumeModel) {
        guard let id = model.id else {
            return nil
        }

        self.id = id
        self.perfumeName = model.perfumeName
        self.brandName = model.brand.name
        self.concentration = model.concentration
        self.fragranceFamily = model.fragranceFamily
        self.seasonProfile = model.seasonProfile
        self.occasionProfile = model.occasionProfile
        self.styleProfile = model.styleProfile
        self.genderProfile = model.genderProfile
        self.moodProfile = model.moodProfile
        self.longevityScore = model.longevityScore
        self.sillageScore = model.sillageScore

        let sortedNotes = model.notes.sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }

        self.topNotes = sortedNotes
            .filter { $0.noteType == .top }
            .map { $0.note.name }
        self.middleNotes = sortedNotes
            .filter { $0.noteType == .middle }
            .map { $0.note.name }
        self.baseNotes = sortedNotes
            .filter { $0.noteType == .base }
            .map { $0.note.name }
        self.accordWeights = Dictionary(
            uniqueKeysWithValues: model.accords.map {
                (PerfumeRecommendationLoader.normalize($0.accord.name), $0.weight)
            }
        )
        self.signature = Self.makeSignature(
            topNotes: self.topNotes,
            middleNotes: self.middleNotes,
            baseNotes: self.baseNotes,
            accordWeights: self.accordWeights,
            concentration: self.concentration,
            fragranceFamily: self.fragranceFamily,
            seasonProfile: self.seasonProfile,
            occasionProfile: self.occasionProfile,
            styleProfile: self.styleProfile,
            genderProfile: self.genderProfile,
            moodProfile: self.moodProfile,
            longevityScore: self.longevityScore,
            sillageScore: self.sillageScore
        )
    }

    private static func makeSignature(
        topNotes: [String],
        middleNotes: [String],
        baseNotes: [String],
        accordWeights: [String: Double],
        concentration: String?,
        fragranceFamily: String?,
        seasonProfile: String?,
        occasionProfile: String?,
        styleProfile: String?,
        genderProfile: String?,
        moodProfile: String?,
        longevityScore: Int?,
        sillageScore: Int?
    ) -> String {
        let noteParts = [
            "top:" + topNotes.map(PerfumeRecommendationLoader.normalize).sorted().joined(separator: ","),
            "middle:" + middleNotes.map(PerfumeRecommendationLoader.normalize).sorted().joined(separator: ","),
            "base:" + baseNotes.map(PerfumeRecommendationLoader.normalize).sorted().joined(separator: ",")
        ]
        let accordParts = accordWeights
            .map { key, value in
                "\(key)=\(String(format: "%.3f", value))"
            }
            .sorted()
            .joined(separator: ",")
        let concentrationPart = PerfumeRecommendationLoader.normalize(concentration ?? "")
        let familyPart = PerfumeRecommendationLoader.normalize(fragranceFamily ?? "")
        let seasonPart = PerfumeRecommendationLoader.normalize(seasonProfile ?? "")
        let occasionPart = PerfumeRecommendationLoader.normalize(occasionProfile ?? "")
        let stylePart = PerfumeRecommendationLoader.normalize(styleProfile ?? "")
        let genderPart = PerfumeRecommendationLoader.normalize(genderProfile ?? "")
        let moodPart = PerfumeRecommendationLoader.normalize(moodProfile ?? "")
        let longevityPart = longevityScore.map(String.init) ?? ""
        let sillagePart = sillageScore.map(String.init) ?? ""

        return [
            noteParts.joined(separator: "|"),
            "accords:\(accordParts)",
            "concentration:\(concentrationPart)",
            "family:\(familyPart)",
            "season:\(seasonPart)",
            "occasion:\(occasionPart)",
            "style:\(stylePart)",
            "gender:\(genderPart)",
            "mood:\(moodPart)",
            "longevity:\(longevityPart)",
            "sillage:\(sillagePart)"
        ].joined(separator: "||")
    }
}
