//
//  CatalogBrand.swift
//  PerfumeSoul
//
//  Created by afon.com on 18.10.2026.
//

import Foundation

struct CatalogBrand: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
}

struct CatalogPerfume: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let brand: String
    let brandID: Int?

    var searchItem: SearchPerfumeItem {
        SearchPerfumeItem(id: id, name: name)
    }
}

struct CatalogPage: Decodable {
    let items: [CatalogPerfume]
    let hasMore: Bool
}
