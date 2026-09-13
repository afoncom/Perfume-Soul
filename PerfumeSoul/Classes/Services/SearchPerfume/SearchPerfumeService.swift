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
        offset: Int,
        limit: Int
    ) async throws -> SearchPerfumePage

    func recordUnfoundSearch(
        query: String,
        context: PerfumeSearchContext
    ) async
}

enum PerfumeSearchContext: String {
    case library
    case similarFinder = "similar_finder"
    case compare
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
        offset: Int,
        limit: Int
    ) async throws -> SearchPerfumePage {
        let response: SearchPerfumePageResponse = try await requestManager.sendRequest(
            request: SearchPerfumeRequest(
                searchText: searchText,
                offset: offset,
                limit: limit
            )
        )

        return SearchPerfumePage(
            items: response.items.map { SearchPerfumeItem(response: $0) },
            hasMore: response.hasMore
        )
    }

    func recordUnfoundSearch(
        query: String,
        context: PerfumeSearchContext
    ) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (3...120).contains(trimmedQuery.count) else {
            return
        }

        let _: UnfoundSearchLogResponse? = try? await requestManager.sendRequest(
            request: UnfoundSearchLogRequest(query: trimmedQuery, context: context)
        )
    }
}
