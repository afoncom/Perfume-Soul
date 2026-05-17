//
//  SimilarPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SimilarPerfumeService {
    func requestSimilarPerfumes() async throws -> [SimilarPerfume]
}

final class SimilarPerfumeServiceImpl {
    let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension SimilarPerfumeServiceImpl: SimilarPerfumeService {
    func requestSimilarPerfumes() async throws -> [SimilarPerfume] {
        let similarPerfumes: [SimilarPerfumeResponse] = try await requestManager.sendRequest(request: SimilarPerfumeRequest())
        return similarPerfumes.map { SimilarPerfume(response: $0) }
    }
}
