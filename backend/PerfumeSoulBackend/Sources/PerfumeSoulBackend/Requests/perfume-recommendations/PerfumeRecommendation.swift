import Fluent
import FluentSQL
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
    private static let candidatePageSize = 1_000

    static func load(
        perfumeIDs: [Int],
        on database: any Database,
        language: String? = nil
    ) async throws -> [PerfumeRecommendation] {
        let selectedPerfumeIDs = uniquePerfumeIDs(from: perfumeIDs)
        guard !selectedPerfumeIDs.isEmpty else {
            return []
        }

        let selectedModels = try await PerfumeModel.query(on: database)
            .withPerfumeProfileFields()
            .filter(\.$id ~~ selectedPerfumeIDs)
            .with(\.$brand)
            .with(\.$notes) { query in query.with(\.$note) }
            .with(\.$accords) { query in query.with(\.$accord) }
            .all()
        let selectedProfiles = selectedModels.compactMap {
            PerfumeProfile(model: $0, language: language)
        }
        guard selectedProfiles.count == selectedPerfumeIDs.count else {
            throw Abort(.notFound)
        }
        let scoreRanges = try await ScoreRanges.load(on: database)
        return try await loadRecommendations(
            selectedPerfumeProfiles: selectedProfiles,
            scoreRanges: scoreRanges,
            pageSize: candidatePageSize,
            eligibleMarketSegmentsOnly: true
        ) { afterID, limit in
            try await PerfumeProfilePageLoader.load(
                afterID: afterID,
                limit: limit,
                language: language,
                on: database
            )
        }
    }
}

enum PerfumeProfilePageLoader {
    static func load(
        afterID: Int?,
        limit: Int,
        marketSegment: PersonalPerfumeMarketSegment? = nil,
        language: String? = nil,
        on database: any Database
    ) async throws -> [PerfumeProfile] {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw Abort(.internalServerError)
        }

        let marketSegments = PersonalPerfumeMarketSegment.allCases.map(\.rawValue)
        let selectedMarketSegment = marketSegment?.rawValue ?? ""
        let rows = try await sqlDatabase.raw("""
            SELECT
                p.id,
                p.perfume_name,
                b.brand AS brand_name,
                p.longevity_score,
                p.sillage_score,
                p.concentration,
                p.fragrance_family,
                p.season_profile,
                p.occasion_profile,
                p.style_profile,
                p.gender_profile,
                p.mood_profile,
                p.market_segment,
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'name', n.name,
                            'nameEnglish', n.name_en,
                            'noteType', pn.note_type,
                            'sortOrder', pn.sort_order
                        )
                        ORDER BY pn.sort_order
                    )
                    FROM perfume_notes pn
                    JOIN notes n ON n.id = pn.note_id
                    WHERE pn.perfume_id = p.id
                ), '[]'::jsonb)::text AS notes_json,
                COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'name', a.name,
                            'weight', pa.weight
                        )
                        ORDER BY a.name
                    )
                    FROM perfume_accords pa
                    JOIN accords a ON a.id = pa.accord_id
                    WHERE pa.perfume_id = p.id
                ), '[]'::jsonb)::text AS accords_json
            FROM perfumes p
            JOIN brands b ON b.id = p.brand_id
            WHERE p.id > \(bind: afterID ?? 0)
                AND p.market_segment = ANY(\(bind: marketSegments))
                AND (\(bind: selectedMarketSegment) = '' OR p.market_segment = \(bind: selectedMarketSegment))
            ORDER BY p.id
            LIMIT \(bind: limit)
            """).all(decoding: SimilarPerfumeProfileRow.self)

        return try rows.map { try $0.makeProfile(language: language) }
    }
}

extension PerfumeRecommendationLoader {
    static func loadRecommendations(
        selectedPerfumeProfiles: [PerfumeProfile],
        scoreRanges: ScoreRanges,
        pageSize: Int,
        eligibleMarketSegmentsOnly: Bool = false,
        pageProvider: (_ afterID: Int?, _ limit: Int) async throws -> [PerfumeProfile]
    ) async throws -> [PerfumeRecommendation] {
        guard pageSize > 0 else {
            return []
        }

        let targetProfile = RecommendationTargetProfile(
            perfumeProfiles: selectedPerfumeProfiles,
            usesLocalizedNoteDisplayNames: selectedPerfumeProfiles.allSatisfy(\.usesLocalizedNoteDisplayNames)
        )
        let selectedIDs = Set(selectedPerfumeProfiles.map(\.id))
        var bestBySignature: [String: ScoredPerfumeRecommendation] = [:]
        var lastID: Int?
        while true {
            let page = try await pageProvider(lastID, pageSize)
            for profile in page where !selectedIDs.contains(profile.id) {
                guard !eligibleMarketSegmentsOnly || profile.marketSegment.flatMap(
                    PersonalPerfumeMarketSegment.init(rawValue:)
                ) != nil else {
                    continue
                }
                guard let scored = makeScoredRecommendation(
                    perfumeProfile: profile,
                    targetProfile: targetProfile,
                    scoreRanges: scoreRanges
                ) else { continue }
                if let current = bestBySignature[scored.signature],
                   !areSortedForRecommendationRanking(lhs: scored, rhs: current) {
                    continue
                }
                bestBySignature[scored.signature] = scored
            }
            bestBySignature = Dictionary(
                uniqueKeysWithValues: bestBySignature.values
                    .sorted(by: areSortedForRecommendationRanking)
                    .prefix(50)
                    .map { ($0.signature, $0) }
            )
            guard page.count == pageSize else { break }
            lastID = page.last?.id
        }

        return Array(bestBySignature.values)
            .sorted(by: areSortedForRecommendationRanking)
            .prefix(5)
            .map(\.recommendation)
    }
}

private struct ScoredPerfumeRecommendation {
    let recommendation: PerfumeRecommendation
    let rawScore: Double
    let signature: String
}

extension PerfumeRecommendationLoader {
    fileprivate static func areSortedForRecommendationRanking(
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

    fileprivate static func makeScoredRecommendation(
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
        let familyComponent = stringSimilarityComponent(
            value: perfumeProfile.fragranceFamily,
            targetValue: targetProfile.fragranceFamily
        )
        let concentrationComponent = stringSimilarityComponent(
            value: perfumeProfile.concentration,
            targetValue: targetProfile.concentration
        )
        let seasonComponent = stringSimilarityComponent(
            value: perfumeProfile.seasonProfile,
            targetValue: targetProfile.seasonProfile
        )
        let occasionComponent = stringSimilarityComponent(
            value: perfumeProfile.occasionProfile,
            targetValue: targetProfile.occasionProfile
        )
        let styleComponent = stringSimilarityComponent(
            value: perfumeProfile.styleProfile,
            targetValue: targetProfile.styleProfile
        )
        let genderComponent = stringSimilarityComponent(
            value: perfumeProfile.genderProfile,
            targetValue: targetProfile.genderProfile
        )
        let moodComponent = stringSimilarityComponent(
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
        var weightedComponents: [(Double, Double)] = [
            (noteScore, 0.27),
            (distinctCoverage, 0.07),
            (noteCountCloseness, 0.03),
            (accordScore, 0.17),
            (accordCountCloseness, 0.03),
            (wearScore, 0.05)
        ]
        appendIfNeeded(familyComponent, weight: 0.07, to: &weightedComponents)
        appendIfNeeded(concentrationComponent, weight: 0.04, to: &weightedComponents)
        appendIfNeeded(seasonComponent, weight: 0.08, to: &weightedComponents)
        appendIfNeeded(occasionComponent, weight: 0.08, to: &weightedComponents)
        appendIfNeeded(styleComponent, weight: 0.08, to: &weightedComponents)
        appendIfNeeded(genderComponent, weight: 0.07, to: &weightedComponents)
        appendIfNeeded(moodComponent, weight: 0.06, to: &weightedComponents)
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

    fileprivate static func makeMatchingNotes(
        targetProfile: RecommendationTargetProfile,
        candidateNoteWeights: [String: Int]
    ) -> [String] {
        targetProfile.noteWeights.keys
            .compactMap { normalizedNote -> (normalizedNote: String, displayName: String, overlapWeight: Int)? in
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

                return (normalizedNote, displayName, overlapWeight)
            }
            .sorted { lhs, rhs in
                if lhs.overlapWeight == rhs.overlapWeight {
                    return lhs.normalizedNote < rhs.normalizedNote
                }

                return lhs.overlapWeight > rhs.overlapWeight
            }
            .prefix(5)
            .map(\.displayName)
    }

    fileprivate static func matchedDistinctNotesCount(
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

    static func stringSimilarityComponent(
        value: String?,
        targetValue: String?
    ) -> Double? {
        if value == nil, targetValue == nil {
            return nil
        }

        return stringSimilarity(value: value, targetValue: targetValue)
    }

    static func appendIfNeeded(
        _ score: Double?,
        weight: Double,
        to components: inout [(Double, Double)]
    ) {
        guard let score else {
            return
        }

        components.append((score, weight))
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

    init(
        perfumeProfiles: [PerfumeProfile],
        usesLocalizedNoteDisplayNames: Bool
    ) {
        var noteWeights: [String: Int] = [:]
        var noteDisplayNames: [String: String] = [:]
        var accordWeights: [String: Double] = [:]

        for perfumeProfile in perfumeProfiles {
            Self.addNotes(
                perfumeProfile.topNotes,
                weight: 3,
                displayNames: usesLocalizedNoteDisplayNames ? perfumeProfile.noteDisplayNames : [:],
                noteWeights: &noteWeights,
                noteDisplayNames: &noteDisplayNames
            )
            Self.addNotes(
                perfumeProfile.middleNotes,
                weight: 2,
                displayNames: usesLocalizedNoteDisplayNames ? perfumeProfile.noteDisplayNames : [:],
                noteWeights: &noteWeights,
                noteDisplayNames: &noteDisplayNames
            )
            Self.addNotes(
                perfumeProfile.baseNotes,
                weight: 1,
                displayNames: usesLocalizedNoteDisplayNames ? perfumeProfile.noteDisplayNames : [:],
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
        displayNames: [String: String],
        noteWeights: inout [String: Int],
        noteDisplayNames: inout [String: String]
    ) {
        for note in notes {
            let normalizedNote = PerfumeRecommendationLoader.normalize(note)
            noteWeights[normalizedNote, default: 0] += weight
            noteDisplayNames[normalizedNote] = displayNames[normalizedNote] ?? note
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

struct ScoreRanges {
    let longevity: ClosedRange<Int>?
    let sillage: ClosedRange<Int>?

    init(perfumeProfiles: [PerfumeProfile]) {
        self.init(
            longevityValues: perfumeProfiles.compactMap(\.longevityScore),
            sillageValues: perfumeProfiles.compactMap(\.sillageScore)
        )
    }

    init(longevityValues: [Int], sillageValues: [Int]) {
        self.longevity = Self.makeRange(values: longevityValues)
        self.sillage = Self.makeRange(values: sillageValues)
    }

    static func load(on database: any Database) async throws -> ScoreRanges {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw Abort(.internalServerError)
        }
        let aggregate = try await sqlDatabase.raw("""
            SELECT
                MIN(longevity_score) AS min_longevity,
                MAX(longevity_score) AS max_longevity,
                MIN(sillage_score) AS min_sillage,
                MAX(sillage_score) AS max_sillage
            FROM perfumes
            WHERE market_segment = ANY(\(bind: PersonalPerfumeMarketSegment.allCases.map(\.rawValue)))
            """).first(decoding: ScoreRangeAggregate.self)
        return ScoreRanges(
            longevityValues: [aggregate?.minLongevity, aggregate?.maxLongevity].compactMap { $0 },
            sillageValues: [aggregate?.minSillage, aggregate?.maxSillage].compactMap { $0 }
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

private struct ScoreRangeAggregate: Decodable {
    let minLongevity: Int?
    let maxLongevity: Int?
    let minSillage: Int?
    let maxSillage: Int?

    enum CodingKeys: String, CodingKey {
        case minLongevity = "min_longevity"
        case maxLongevity = "max_longevity"
        case minSillage = "min_sillage"
        case maxSillage = "max_sillage"
    }
}

struct SimilarPerfumeProfileRow: Decodable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let marketSegment: String?
    let notesJSON: String
    let accordsJSON: String

    enum CodingKeys: String, CodingKey {
        case id
        case perfumeName = "perfume_name"
        case brandName = "brand_name"
        case longevityScore = "longevity_score"
        case sillageScore = "sillage_score"
        case concentration = "concentration"
        case fragranceFamily = "fragrance_family"
        case seasonProfile = "season_profile"
        case occasionProfile = "occasion_profile"
        case styleProfile = "style_profile"
        case genderProfile = "gender_profile"
        case moodProfile = "mood_profile"
        case marketSegment = "market_segment"
        case notesJSON = "notes_json"
        case accordsJSON = "accords_json"
    }

    func makeProfile(language: String?) throws -> PerfumeProfile {
        let decoder = JSONDecoder()
        let notes = try decoder.decode([Note].self, from: Data(notesJSON.utf8)).map { note in
            guard let noteType = PerfumeNoteType(rawValue: note.noteType) else {
                throw Abort(.internalServerError, reason: "Unexpected perfume note type.")
            }
            return PerfumeProfileNote(
                name: note.name,
                nameEnglish: note.nameEnglish,
                noteType: noteType,
                sortOrder: note.sortOrder
            )
        }
        let accords = try decoder.decode([Accord].self, from: Data(accordsJSON.utf8)).map {
            PerfumeProfileAccord(name: $0.name, weight: $0.weight)
        }

        return PerfumeProfile(
            id: id,
            perfumeName: perfumeName,
            brandName: brandName,
            longevityScore: longevityScore,
            sillageScore: sillageScore,
            concentration: concentration,
            fragranceFamily: fragranceFamily,
            seasonProfile: seasonProfile,
            occasionProfile: occasionProfile,
            styleProfile: styleProfile,
            genderProfile: genderProfile,
            moodProfile: moodProfile,
            marketSegment: marketSegment,
            profileNotes: notes,
            profileAccords: accords,
            language: language
        )
    }

    struct Note: Decodable {
        let name: String
        let nameEnglish: String?
        let noteType: String
        let sortOrder: Int
    }

    struct Accord: Decodable {
        let name: String
        let weight: Double
    }
}

struct PerfumeProfileNote: Sendable {
    let name: String
    let nameEnglish: String?
    let noteType: PerfumeNoteType
    let sortOrder: Int
}

struct PerfumeProfileAccord: Sendable {
    let name: String
    let weight: Double
}

struct PerfumeProfile: Sendable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
    let noteDisplayNames: [String: String]
    let usesLocalizedNoteDisplayNames: Bool
    let accordWeights: [String: Double]
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let marketSegment: String?
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
        noteDisplayNames: [String: String] = [:],
        usesLocalizedNoteDisplayNames: Bool = false,
        accordWeights: [String: Double] = [:],
        concentration: String? = nil,
        fragranceFamily: String? = nil,
        seasonProfile: String? = nil,
        occasionProfile: String? = nil,
        styleProfile: String? = nil,
        genderProfile: String? = nil,
        moodProfile: String? = nil,
        marketSegment: String? = nil
    ) {
        self.id = id
        self.perfumeName = perfumeName
        self.brandName = brandName
        self.longevityScore = longevityScore
        self.sillageScore = sillageScore
        self.topNotes = topNotes
        self.middleNotes = middleNotes
        self.baseNotes = baseNotes
        self.noteDisplayNames = noteDisplayNames
        self.usesLocalizedNoteDisplayNames = usesLocalizedNoteDisplayNames
        self.accordWeights = accordWeights
        self.concentration = concentration
        self.fragranceFamily = fragranceFamily
        self.seasonProfile = seasonProfile
        self.occasionProfile = occasionProfile
        self.styleProfile = styleProfile
        self.genderProfile = genderProfile
        self.moodProfile = moodProfile
        self.marketSegment = marketSegment
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

    init(
        id: Int,
        perfumeName: String,
        brandName: String,
        longevityScore: Int?,
        sillageScore: Int?,
        concentration: String?,
        fragranceFamily: String?,
        seasonProfile: String?,
        occasionProfile: String?,
        styleProfile: String?,
        genderProfile: String?,
        moodProfile: String?,
        marketSegment: String?,
        profileNotes: [PerfumeProfileNote],
        profileAccords: [PerfumeProfileAccord],
        language: String?
    ) {
        let sortedNotes = profileNotes.sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }
        let isEnglish = PerfumeNotesLoader.prefersEnglish(acceptLanguage: language)
        let useEnglishNotes = isEnglish && !sortedNotes.isEmpty && sortedNotes.allSatisfy {
            $0.nameEnglish?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
        var noteDisplayNames: [String: String] = [:]
        for note in sortedNotes {
            let displayName = useEnglishNotes
                ? note.nameEnglish!.trimmingCharacters(in: .whitespacesAndNewlines)
                : note.name
            noteDisplayNames[PerfumeRecommendationLoader.normalize(note.name)] = displayName
        }

        self.init(
            id: id,
            perfumeName: perfumeName,
            brandName: brandName,
            longevityScore: longevityScore,
            sillageScore: sillageScore,
            topNotes: sortedNotes.filter { $0.noteType == .top }.map(\.name),
            middleNotes: sortedNotes.filter { $0.noteType == .middle }.map(\.name),
            baseNotes: sortedNotes.filter { $0.noteType == .base }.map(\.name),
            noteDisplayNames: noteDisplayNames,
            usesLocalizedNoteDisplayNames: useEnglishNotes,
            accordWeights: Dictionary(
                uniqueKeysWithValues: profileAccords.map {
                    (PerfumeRecommendationLoader.normalize($0.name), $0.weight)
                }
            ),
            concentration: concentration,
            fragranceFamily: fragranceFamily,
            seasonProfile: seasonProfile,
            occasionProfile: occasionProfile,
            styleProfile: styleProfile,
            genderProfile: genderProfile,
            moodProfile: moodProfile,
            marketSegment: marketSegment
        )
    }

    init?(model: PerfumeModel, language: String? = nil) {
        guard let id = model.id else {
            return nil
        }

        self.init(
            id: id,
            perfumeName: model.perfumeName,
            brandName: model.brand.name,
            longevityScore: model.longevityScore,
            sillageScore: model.sillageScore,
            concentration: model.concentration,
            fragranceFamily: model.fragranceFamily,
            seasonProfile: model.seasonProfile,
            occasionProfile: model.occasionProfile,
            styleProfile: model.styleProfile,
            genderProfile: model.genderProfile,
            moodProfile: model.moodProfile,
            marketSegment: model.marketSegment,
            profileNotes: model.notes.map {
                PerfumeProfileNote(
                    name: $0.note.name,
                    nameEnglish: $0.note.nameEnglish,
                    noteType: $0.noteType,
                    sortOrder: $0.sortOrder
                )
            },
            profileAccords: model.accords.map {
                PerfumeProfileAccord(name: $0.accord.name, weight: $0.weight)
            },
            language: language
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

extension QueryBuilder where Model == PerfumeModel {
    /// Fields read by `PerfumeProfile.init(model:)`.
    func withPerfumeProfileFields() -> Self {
        field(\.$id)
            .field(\.$perfumeName)
            .field(\.$longevityScore)
            .field(\.$sillageScore)
            .field(\.$concentration)
            .field(\.$fragranceFamily)
            .field(\.$seasonProfile)
            .field(\.$occasionProfile)
            .field(\.$styleProfile)
            .field(\.$genderProfile)
            .field(\.$moodProfile)
            .field(\.$marketSegment)
            .field(\.$brand.$id)
    }
}
