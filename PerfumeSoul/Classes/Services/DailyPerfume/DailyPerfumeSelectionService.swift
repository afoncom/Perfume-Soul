//
//  DailyPerfumeSelectionService.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol DailyPerfumeRandomSource {
    func nextUnitInterval() -> Double
}

struct SystemDailyPerfumeRandomSource: DailyPerfumeRandomSource {
    func nextUnitInterval() -> Double {
        Double.random(in: 0..<1)
    }
}

protocol DailyPerfumeSelectionService {
    func selectCandidate(
        from candidates: [DailyPerfumeCandidateResponse]
    ) -> DailyPerfumeCandidateResponse?
}

final class DailyPerfumeSelectionServiceImpl {
    private static let temperature = 0.08

    private let randomSource: DailyPerfumeRandomSource

    init(randomSource: DailyPerfumeRandomSource) {
        self.randomSource = randomSource
    }
}

extension DailyPerfumeSelectionServiceImpl: DailyPerfumeSelectionService {
    func selectCandidate(
        from candidates: [DailyPerfumeCandidateResponse]
    ) -> DailyPerfumeCandidateResponse? {
        guard let maximumNatalScore = candidates.map(\.natalScore).max() else {
            return nil
        }

        let weights = candidates.map {
            exp(($0.natalScore - maximumNatalScore) / Self.temperature)
        }
        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else {
            return candidates.first
        }

        let randomValue = min(max(randomSource.nextUnitInterval(), 0), 0.999_999_999)
        let selectionTarget = randomValue * totalWeight
        var cumulativeWeight = 0.0

        for (candidate, weight) in zip(candidates, weights) {
            cumulativeWeight += weight
            if selectionTarget < cumulativeWeight {
                return candidate
            }
        }

        return candidates.last
    }
}
