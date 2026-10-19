//
//  CatalogService.swift
//  PerfumeSoul
//
//  Created by afon.com on 18.10.2026.
//

import Foundation

protocol CatalogService {
    func brands() async throws -> [CatalogBrand]
    func perfumes(search: String, brandID: Int?, offset: Int) async throws -> CatalogPage
}

final class CatalogServiceImpl: CatalogService {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }

    func brands() async throws -> [CatalogBrand] {
        try await requestManager.sendRequest(request: CatalogBrandsRequest())
    }

    func perfumes(search: String, brandID: Int?, offset: Int) async throws -> CatalogPage {
        try await requestManager.sendRequest(
            request: CatalogPerfumesRequest(search: search, brandID: brandID, offset: offset)
        )
    }
}

private struct CatalogBrandsRequest: Request {
    let path = "/catalog/brands"
    let httpMethod: HTTPMethod = .get
}

private struct CatalogPerfumesRequest: Request {
    let path = "/catalog/perfumes"
    let httpMethod: HTTPMethod = .get
    let search: String
    let brandID: Int?
    let offset: Int

    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "searchText", value: search),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: "30")
        ]
        if let brandID {
            items.append(URLQueryItem(name: "brandID", value: String(brandID)))
        }
        return items
    }
}
