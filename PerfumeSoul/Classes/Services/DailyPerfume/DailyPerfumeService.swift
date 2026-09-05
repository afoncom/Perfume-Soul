//
//  DailyPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DailyPerfumeService {
    func requestCandidates(
        profile: DailyPerfumeProfileRequest,
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
        profile: DailyPerfumeProfileRequest,
        excludedPerfumeIDs: [Int],
        lastShownBrand: String?,
        limit: Int
    ) async throws -> [DailyPerfumeCandidateResponse] {
        try await requestManager.sendRequest(
            request: DailyPerfumeRequest(
                profile: profile,
                excludedPerfumeIDs: excludedPerfumeIDs,
                lastShownBrand: lastShownBrand,
                limit: limit
            )
        )
    }
}
