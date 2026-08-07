//
//  PerfumeDetailsRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation

struct PerfumeDetailsRequest: Request {
    let perfumeID: Int
    let httpMethod: HTTPMethod = .get

    var path: String {
        "/perfumes/\(perfumeID)/notes"
    }

    var headers: [String: String] {
        ["Accept-Language": Locale.preferredLanguages.first ?? Locale.current.identifier]
    }
}
