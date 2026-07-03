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
            .all()

        let perfumeProfiles = perfumeModels.compactMap(PerfumeProfile.init(model:))
        let selectedPerfumeProfiles = selectedPerfumeIDs.compactMap { perfumeID in
            perfumeProfiles.first(where: { $0.id == perfumeID })
        }

        guard selectedPerfumeProfiles.count == selectedPerfumeIDs.count else {
            throw Abort(.notFound)
        }

        let targetProfile = RecommendationTargetProfile(perfumeProfiles: selectedPerfumeProfiles)
        let scoreRanges = ScoreRanges(perfumeProfiles: perfumeProfiles)

        return perfumeProfiles
            .filter { !selectedPerfumeIDs.contains($0.id) }
            .compactMap { perfumeProfile in
                makeRecommendation(
                    perfumeProfile: perfumeProfile,
                    targetProfile: targetProfile,
                    scoreRanges: scoreRanges
                )
            }
            .sorted { lhs, rhs in
                if lhs.matchPercentage == rhs.matchPercentage {
                    if lhs.brandName == rhs.brandName {
                        return lhs.perfumeName < rhs.perfumeName
                    }

                    return lhs.brandName < rhs.brandName
                }

                return lhs.matchPercentage > rhs.matchPercentage
            }
            .prefix(5)
            .map { $0 }
    }
}

private extension PerfumeRecommendationLoader {
    static func uniquePerfumeIDs(from perfumeIDs: [Int]) -> [Int] {
        var seenPerfumeIDs = Set<Int>()
        var uniquePerfumeIDs: [Int] = []

        for perfumeID in perfumeIDs where seenPerfumeIDs.insert(perfumeID).inserted {
            uniquePerfumeIDs.append(perfumeID)
        }

        return Array(uniquePerfumeIDs.prefix(3))
    }

    static func makeRecommendation(
        perfumeProfile: PerfumeProfile,
        targetProfile: RecommendationTargetProfile,
        scoreRanges: ScoreRanges
    ) -> PerfumeRecommendation? {
        let candidateNoteWeights = noteWeights(for: perfumeProfile)
        let matchingNotes = makeMatchingNotes(
            targetProfile: targetProfile,
            candidateNoteWeights: candidateNoteWeights
        )

        guard !matchingNotes.isEmpty else {
            return nil
        }

        let noteSimilarity = weightedJaccardSimilarity(
            lhs: targetProfile.noteWeights,
            rhs: candidateNoteWeights
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

        let rawScore =
            noteSimilarity * 0.7
            + longevitySimilarity * 0.15
            + sillageSimilarity * 0.15
        let matchPercentage = Int((rawScore * 100).rounded(.toNearestOrAwayFromZero))

        return PerfumeRecommendation(
            id: perfumeProfile.id,
            perfumeName: perfumeProfile.perfumeName,
            brandName: perfumeProfile.brandName,
            matchingNotes: matchingNotes,
            matchPercentage: matchPercentage,
            longevityScore: perfumeProfile.longevityScore,
            sillageScore: perfumeProfile.sillageScore
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

    static func weightedJaccardSimilarity(
        lhs: [String: Int],
        rhs: [String: Int]
    ) -> Double {
        let allKeys = Set(lhs.keys).union(rhs.keys)
        guard !allKeys.isEmpty else {
            return 0
        }

        let overlapWeight = allKeys.reduce(0) { partialResult, key in
            partialResult + min(lhs[key] ?? 0, rhs[key] ?? 0)
        }
        let unionWeight = allKeys.reduce(0) { partialResult, key in
            partialResult + max(lhs[key] ?? 0, rhs[key] ?? 0)
        }

        guard unionWeight > 0 else {
            return 0
        }

        return Double(overlapWeight) / Double(unionWeight)
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

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

private struct RecommendationTargetProfile {
    let noteWeights: [String: Int]
    let noteDisplayNames: [String: String]
    let averageLongevityScore: Double?
    let averageSillageScore: Double?

    init(perfumeProfiles: [PerfumeProfile]) {
        var noteWeights: [String: Int] = [:]
        var noteDisplayNames: [String: String] = [:]

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
        }

        self.noteWeights = noteWeights
        self.noteDisplayNames = noteDisplayNames
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

    private static func average(values: [Int]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        let total = values.reduce(0, +)
        return Double(total) / Double(values.count)
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

private struct PerfumeProfile {
    let id: Int
    let perfumeName: String
    let brandName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]

    init?(model: PerfumeModel) {
        guard let id = model.id else {
            return nil
        }

        self.id = id
        self.perfumeName = model.perfumeName
        self.brandName = model.brand.name
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
    }
}
