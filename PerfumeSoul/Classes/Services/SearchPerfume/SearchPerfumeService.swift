//
//  SearchPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SearchPerfumeService {
    func requestPerfumes(
        searchText: String,
        page: Int,
        itemsPerPage: Int
    ) async throws -> [SearchPerfumeItem]
}

final class SearchPerfumeServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension SearchPerfumeServiceImpl: SearchPerfumeService {
    func requestPerfumes(
        searchText: String,
        page: Int,
        itemsPerPage: Int
    ) async throws -> [SearchPerfumeItem] {
        let perfumes: [SearchPerfumeResponse] = try await requestManager.sendRequest(
            request: SearchPerfumeRequest(
                searchText: searchText,
                page: page,
                itemsPerPage: itemsPerPage
            )
        )
        return perfumes.map { SearchPerfumeItem(response: $0) }
    }
}
