import Fluent
import Vapor

enum RecommendedPerfumeCandidateLoader {
    static func load(
        request: DailyPerfumeCandidatesRequest,
        on database: any Database
    ) async throws -> [DailyPerfumeCandidate] {
        let candidates = try await DailyPerfumeCandidateLoader.loadRankedCandidates(
            request: request,
            on: database
        )
        return candidatesApplyingBrandCap(candidates, limit: request.limit)
    }

    static func candidatesApplyingBrandCap(
        _ candidates: [DailyPerfumeCandidate],
        limit: Int
    ) -> [DailyPerfumeCandidate] {
        let requiredCount = min(limit, DailyPerfumeCandidateLoader.maximumCandidateLimit)
        for maximumPerBrand in [2, 3, Int.max] {
            let selected = candidatesWithBrandCap(candidates, maximumPerBrand: maximumPerBrand)
            if selected.count >= requiredCount || maximumPerBrand == Int.max {
                return Array(selected.prefix(requiredCount))
            }
        }
        return []
    }
}

private extension RecommendedPerfumeCandidateLoader {
    static func candidatesWithBrandCap(
        _ candidates: [DailyPerfumeCandidate],
        maximumPerBrand: Int
    ) -> [DailyPerfumeCandidate] {
        var brandCounts: [String: Int] = [:]
        return candidates.filter { candidate in
            let brand = candidate.brandName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            let count = brandCounts[brand, default: 0]
            guard count < maximumPerBrand else {
                return false
            }
            brandCounts[brand] = count + 1
            return true
        }
    }
}
