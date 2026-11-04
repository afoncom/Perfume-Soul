//
//  DailyPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DailyPerfumeService {
    func requestCandidates(
        calculation: ProfileCalculation,
        excludedPerfumeIDs: [Int],
        lastShownBrand: String?,
        limit: Int
    ) async throws -> [DailyPerfumeCandidateResponse]
}

final class DailyPerfumeServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension DailyPerfumeServiceImpl: DailyPerfumeService {
    func requestCandidates(
        calculation: ProfileCalculation,
        excludedPerfumeIDs: [Int],
        lastShownBrand: String?,
        limit: Int
    ) async throws -> [DailyPerfumeCandidateResponse] {
        try await requestManager.sendRequest(
            request: DailyPerfumeRequest(
                profile: makeProfileData(for: calculation),
                excludedPerfumeIDs: excludedPerfumeIDs,
                lastShownBrand: lastShownBrand,
                limit: limit
            )
        )
    }
}

private extension DailyPerfumeServiceImpl {
    func makeProfileData(for calculation: ProfileCalculation) -> DailyPerfumeProfile {
        DailyPerfumeProfile(
            sun: calculation.natalChart.sun.sign.rawValue,
            moon: calculation.natalChart.moon.sign.rawValue,
            ascendant: calculation.natalChart.ascendant.sign.rawValue,
            elementBalance: DailyPerfumeElementBalance(
                fire: calculation.elementBalance.fire,
                earth: calculation.elementBalance.earth,
                air: calculation.elementBalance.air,
                water: calculation.elementBalance.water
            )
        )
    }
}
