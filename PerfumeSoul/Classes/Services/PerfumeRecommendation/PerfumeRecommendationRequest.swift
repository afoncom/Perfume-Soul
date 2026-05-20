//
//  PerfumeRecommendationRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct PerfumeRecommendationRequest: Request {
    let path: String = "/perfumes/recommendations"
    let httpMethod: HTTPMethod = .get
}
