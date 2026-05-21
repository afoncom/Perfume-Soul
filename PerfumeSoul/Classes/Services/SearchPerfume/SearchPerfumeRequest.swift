//
//  SearchPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct SearchPerfumeRequest: Request {
    let path: String = "/perfumes/perfumes"
    let httpMethod: HTTPMethod = .get

    let searchText: String
    let page: Int
    let itemsPerPage: Int

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "searchText", value: searchText),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "itemsPerPage", value: String(itemsPerPage))
        ]
    }
}
