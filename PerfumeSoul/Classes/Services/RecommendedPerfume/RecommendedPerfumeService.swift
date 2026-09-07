//
//  RecommendedPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import Foundation

protocol RecommendedPerfumeService {
    func requestCandidates(profile: DailyPerfumeProfileRequest, excludedPerfumeIDs: [Int], limit: Int) async throws -> [DailyPerfumeCandidateResponse]
}

final class RecommendedPerfumeServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension RecommendedPerfumeServiceImpl: RecommendedPerfumeService {
    func requestCandidates(profile: DailyPerfumeProfileRequest, excludedPerfumeIDs: [Int], limit: Int) async throws -> [DailyPerfumeCandidateResponse] {
        try await requestManager.sendRequest(request: RecommendedPerfumeRequest(profile: profile, excludedPerfumeIDs: excludedPerfumeIDs, limit: limit))
    }
}

private struct RecommendedPerfumeRequest: Request {
    let profile: DailyPerfumeProfileRequest
    let excludedPerfumeIDs: [Int]
    let limit: Int
    let path = "/recommended-perfumes/candidates"
    let httpMethod: HTTPMethod = .post

    var httpBody: Data? {
        try? JSONEncoder().encode(Body(sun: profile.sun, moon: profile.moon, ascendant: profile.ascendant, elementBalance: profile.elementBalance, excludedPerfumeIDs: excludedPerfumeIDs, lastShownBrand: nil, limit: limit))
    }

    private struct Body: Encodable {
        let sun: String
        let moon: String
        let ascendant: String
        let elementBalance: DailyPerfumeElementBalanceRequest
        let excludedPerfumeIDs: [Int]
        let lastShownBrand: String?
        let limit: Int
    }
}
