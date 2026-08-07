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
}
