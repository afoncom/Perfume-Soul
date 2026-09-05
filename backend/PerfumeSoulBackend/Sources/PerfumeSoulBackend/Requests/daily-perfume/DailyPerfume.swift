import Fluent
import Foundation
import Vapor

struct DailyPerfumeCandidatesRequest: Content {
    let sun: ZodiacSign
    let moon: ZodiacSign
    let ascendant: ZodiacSign
    let elementBalance: ElementBalance
    let excludedPerfumeIDs: [Int]
    let lastShownBrand: String?
    let limit: Int

    func validate() throws {
        try PersonalPerfumesRequest(
            sun: sun,
            moon: moon,
            ascendant: ascendant,
            elementBalance: elementBalance
        ).validateElementBalance()

        guard limit > 0 else {
            throw Abort(
                .badRequest,
                reason: "limit must be greater than zero"
            )
        }
    }
}

struct DailyPerfumeCandidate: Content, Equatable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let natalScore: Double
}

enum DailyPerfumeCandidateLoader {
    static let maximumCandidateLimit = 20
    private static let candidatePageSize = 100

    static func load(
        request: DailyPerfumeCandidatesRequest,
        on database: any Database
    ) async throws -> [DailyPerfumeCandidate] {
        try await loadCandidates(
            request: request,
            pageSize: candidatePageSize
        ) { offset, limit in
            let perfumeModels = try await loadCandidates(
                offset: offset,
                limit: limit,
                on: database
            )

            return perfumeModels.compactMap { PerfumeProfile(model: $0) }
        }
    }

    static func loadCandidates(
        request: DailyPerfumeCandidatesRequest,
        pageSize: Int,
        pageProvider: (_ offset: Int, _ limit: Int) async throws -> [PerfumeProfile]
    ) async throws -> [DailyPerfumeCandidate] {
        var offset = 0
        var perfumeProfiles: [PerfumeProfile] = []

        while true {
            let page = try await pageProvider(offset, pageSize)
            perfumeProfiles += page

            guard page.count == pageSize else {
                break
            }

            offset += pageSize
        }

        let excludedPerfumeIDs = Set(request.excludedPerfumeIDs)
        let personalPerfumesRequest = PersonalPerfumesRequest(
            sun: request.sun,
            moon: request.moon,
            ascendant: request.ascendant,
            elementBalance: request.elementBalance
        )
        let rankedCandidates = PersonalPerfumeScorer.rankedCandidates(
            request: personalPerfumesRequest,
            perfumeProfiles: perfumeProfiles
        )
            .filter { !excludedPerfumeIDs.contains($0.id) }
            .sorted(by: PersonalPerfumeScorer.areSortedForDailyCandidateRanking)
        let uniqueCandidates = uniqueBySignature(rankedCandidates)
        let candidates = candidatesAvoidingLastShownBrand(
            uniqueCandidates,
            lastShownBrand: request.lastShownBrand
        )

        return candidates
            .prefix(min(request.limit, maximumCandidateLimit))
            .map {
                DailyPerfumeCandidate(
                    id: $0.id,
                    perfumeName: $0.perfumeName,
                    brandName: $0.brandName,
                    natalScore: $0.rawScore
                )
            }
    }
}

private extension DailyPerfumeCandidateLoader {
    static func loadCandidates(
        offset: Int,
        limit: Int,
        on database: any Database
    ) async throws -> [PerfumeModel] {
        try await PerfumeModel.query(on: database)
            .withPerfumeProfileFields()
            .sort(\.$id)
            .range(offset..<(offset + limit))
            .with(\.$brand)
            .with(\.$notes) { query in
                query.with(\.$note)
            }
            .with(\.$accords) { query in
                query.with(\.$accord)
            }
            .all()
    }

    static func uniqueBySignature(
        _ candidates: [RankedPersonalPerfume]
    ) -> [RankedPersonalPerfume] {
        var seenSignatures = Set<String>()
        var uniqueCandidates: [RankedPersonalPerfume] = []

        for candidate in candidates where seenSignatures.insert(candidate.signature).inserted {
            uniqueCandidates.append(candidate)
        }

        return uniqueCandidates
    }

    static func candidatesAvoidingLastShownBrand(
        _ candidates: [RankedPersonalPerfume],
        lastShownBrand: String?
    ) -> [RankedPersonalPerfume] {
        guard let lastShownBrand else {
            return candidates
        }

        let candidatesWithDifferentBrand = candidates.filter {
            normalizedBrandName($0.brandName) != normalizedBrandName(lastShownBrand)
        }

        return candidatesWithDifferentBrand.isEmpty ? candidates : candidatesWithDifferentBrand
    }

    static func normalizedBrandName(_ brandName: String) -> String {
        brandName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
