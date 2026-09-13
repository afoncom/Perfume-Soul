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

struct UnfoundSearchLogRequest: Request {
    let query: String
    let context: PerfumeSearchContext
    let path = "/perfumes/unfound-searches"
    let httpMethod: HTTPMethod = .post

    var httpBody: Data? {
        try? JSONEncoder().encode(Body(query: query, context: context.rawValue))
    }

    private struct Body: Encodable {
        let query: String
        let context: String
    }
}

struct UnfoundSearchLogResponse: Decodable {
    let accepted: Bool
}
