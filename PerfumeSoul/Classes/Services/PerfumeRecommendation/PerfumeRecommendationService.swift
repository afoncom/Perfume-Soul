//
//  PerfumeRecommendationService.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeRecommendationService {
    func requestPerfumeRecommendations() async throws -> [PerfumeRecommendation]
}

final class PerfumeRecommendationServiceImpl {
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension PerfumeRecommendationServiceImpl: PerfumeRecommendationService {
    func requestPerfumeRecommendations() async throws -> [PerfumeRecommendation] {
        let perfumeRecommendations: [PerfumeRecommendationResponse] = try await requestManager.sendRequest(
            request: PerfumeRecommendationRequest()
        )
        return perfumeRecommendations.map { PerfumeRecommendation(response: $0) }
    }
}
