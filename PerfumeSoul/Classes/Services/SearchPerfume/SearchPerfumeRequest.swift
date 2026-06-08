//
//  SearchPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct SearchPerfumeRequest: Request {
    let path: String = "/perfumes"
    let httpMethod: HTTPMethod = .get

    let searchText: String
    let offset: Int
    let limit: Int

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "searchText", value: searchText),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
    }
}
