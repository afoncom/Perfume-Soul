//
//  ListPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ListPerfumeService {
    func requestListPerfume() async throws -> [ListPerfume]
}

final class ListPerfumeServiceImpl {
    let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension ListPerfumeServiceImpl: ListPerfumeService {
    func requestListPerfume() async throws -> [ListPerfume] {
        let listPerfumes: [ListPerfumeResponse] = try await requestManager.sendRequest(request: ListPerfumeRequest())
        return listPerfumes.map { ListPerfume(response: $0) }
    }
}
