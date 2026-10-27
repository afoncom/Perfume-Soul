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
    let imageURL: URL?

    init(id: Int, name: String, brand: String, brandID: Int?, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.brandID = brandID
        self.imageURL = imageURL
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, brand, brandID, imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decode(String.self, forKey: .brand)
        brandID = try container.decodeIfPresent(Int.self, forKey: .brandID)
        let value = try? container.decode(String.self, forKey: .imageURL)
        if let value, let url = URL(string: value), url.scheme?.lowercased() == "https", url.host != nil {
            imageURL = url
        } else {
            imageURL = nil
        }
    }

    var searchItem: SearchPerfumeItem {
        SearchPerfumeItem(id: id, name: name)
    }
}

struct CatalogPage: Decodable {
    let items: [CatalogPerfume]
    let hasMore: Bool
}
