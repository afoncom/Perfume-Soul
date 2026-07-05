//
//  PerfumeRecommendationRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PerfumeRecommendationRequest: Request {
    let perfumeIDs: [Int]
    let path: String = "/perfumes/recommendations"
    let httpMethod: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(
                name: "perfumeIDs",
                value: perfumeIDs.map(String.init).joined(separator: ",")
            )
        ]
    }
}
