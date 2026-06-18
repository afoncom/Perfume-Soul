//
//  ComparePerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ComparePerfumeService {
    func requestPerfume(perfumeID: Int) async throws -> ComparePerfume
}

final class ComparePerfumeServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension ComparePerfumeServiceImpl: ComparePerfumeService {
    func requestPerfume(perfumeID: Int) async throws -> ComparePerfume {
        let response: ComparePerfumeResponse = try await requestManager.sendRequest(
            request: ComparePerfumeRequest(perfumeID: perfumeID)
        )

        return ComparePerfume(response: response)
    }
}
