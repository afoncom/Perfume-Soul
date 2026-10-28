//
//  PerfumeDetailsService.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation

protocol PerfumeDetailsService {
    func requestPerfumeDetails(perfumeID: Int) async throws -> PerfumeDetails
    func requestPerfumeImage(perfumeID: Int) async throws -> URL?
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

    func requestPerfumeImage(perfumeID: Int) async throws -> URL? {
        let response: PerfumeImageResponse = try await requestManager.sendRequest(
            request: PerfumeImageRequest(perfumeID: perfumeID)
        )
        return response.imageURL.flatMap(URL.init(string:))
    }
}

private struct PerfumeImageResponse: Decodable {
    let imageURL: String?
}
