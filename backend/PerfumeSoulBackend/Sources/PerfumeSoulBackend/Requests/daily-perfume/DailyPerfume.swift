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
    private static let candidatePageSize = 1_000
    private static let candidatePoolLimit = 100

    static func load(
        request: DailyPerfumeCandidatesRequest,
        on database: any Database
    ) async throws -> [DailyPerfumeCandidate] {
        return try await loadCandidates(
            request: request,
            pageSize: candidatePageSize
        ) { afterID, limit in
            try await PerfumeProfilePageLoader.load(
                afterID: afterID,
                limit: limit,
                on: database
            )
        }
    }

    static func loadCandidates(
        request: DailyPerfumeCandidatesRequest,
        pageSize: Int,
        pageProvider: (_ afterID: Int?, _ limit: Int) async throws -> [PerfumeProfile]
    ) async throws -> [DailyPerfumeCandidate] {
        let candidates = try await loadRankedCandidates(
            request: request,
            pageSize: pageSize,
            pageProvider: pageProvider
        )

        return Array(candidates.prefix(min(request.limit, maximumCandidateLimit)))
    }

    static func loadRankedCandidates(
        request: DailyPerfumeCandidatesRequest,
        on database: any Database
    ) async throws -> [DailyPerfumeCandidate] {
        return try await loadRankedCandidates(
            request: request,
            pageSize: candidatePageSize
        ) { afterID, limit in
            try await PerfumeProfilePageLoader.load(
                afterID: afterID,
                limit: limit,
                on: database
            )
        }
    }

    static func loadRankedCandidates(
        request: DailyPerfumeCandidatesRequest,
        pageSize: Int,
        pageProvider: (_ afterID: Int?, _ limit: Int) async throws -> [PerfumeProfile]
    ) async throws -> [DailyPerfumeCandidate] {
        var lastID: Int?
        var rankedCandidates: [RankedPersonalPerfume] = []
        let excludedPerfumeIDs = Set(request.excludedPerfumeIDs)
        let personalPerfumesRequest = PersonalPerfumesRequest(
            sun: request.sun,
            moon: request.moon,
            ascendant: request.ascendant,
            elementBalance: request.elementBalance
        )

        while true {
            let page = try await pageProvider(lastID, pageSize)
            let pageCandidates = PersonalPerfumeScorer.rankedCandidates(
                request: personalPerfumesRequest,
                perfumeProfiles: page
            )
                .filter { !excludedPerfumeIDs.contains($0.id) }
            rankedCandidates = keepingTopCandidates(rankedCandidates + pageCandidates)

            guard page.count == pageSize else {
                break
            }

            lastID = page.last?.id
        }

        let uniqueCandidates = uniqueBySignature(rankedCandidates)
        let candidates = candidatesAvoidingLastShownBrand(
            uniqueCandidates,
            lastShownBrand: request.lastShownBrand
        )

        return candidates.map {
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
    static func keepingTopCandidates(
        _ candidates: [RankedPersonalPerfume]
    ) -> [RankedPersonalPerfume] {
        Array(
            candidates
                .sorted(by: PersonalPerfumeScorer.areSortedForDailyCandidateRanking)
                .prefix(candidatePoolLimit)
        )
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
