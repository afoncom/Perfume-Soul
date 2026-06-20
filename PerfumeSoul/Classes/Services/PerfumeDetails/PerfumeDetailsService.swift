//
//  PerfumeDetailsService.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

protocol PerfumeDetailsService {
    func requestPerfumeDetails(perfumeID: Int) async throws -> PerfumeDetails
}

final class PerfumeDetailsServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension PerfumeDetailsServiceImpl: PerfumeDetailsService {
    func requestPerfumeDetails(perfumeID: Int) async throws -> PerfumeDetails {
        let response: PerfumeDetailsResponse = try await requestManager.sendRequest(
            request: PerfumeDetailsRequest(perfumeID: perfumeID)
        )

        return PerfumeDetails(response: response)
    }
}
