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
                profile: DailyPerfumeProfile(calculation: calculation),
                excludedPerfumeIDs: excludedPerfumeIDs,
                lastShownBrand: lastShownBrand,
                limit: limit
            )
        )
    }
}
