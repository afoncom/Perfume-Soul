//
//  PerfumeHistoryService.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeHistoryService {
    func requestPerfumeHistory() async throws -> [PerfumeInHistoryResponse]
}

final class PerfumeHistoryServiceImpl {
    let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension PerfumeHistoryServiceImpl: PerfumeHistoryService {
    func requestPerfumeHistory() async throws -> [PerfumeInHistoryResponse] {
        let perfumesInHistory: [PerfumeInHistoryResponse] = try await requestManager.sendRequest(request: PerfumeHistoryRequest())
        return perfumesInHistory
    }
}
