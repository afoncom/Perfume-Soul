//
//  PerfumeRecommendationResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PerfumeRecommendationResponse: Decodable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let matchingNotes: [String]
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
}
