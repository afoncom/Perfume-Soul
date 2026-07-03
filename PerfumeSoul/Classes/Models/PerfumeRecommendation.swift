//
//  PerfumeRecommendation.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PerfumeRecommendation {
    let id: Int
    let perfumeName: String
    let brandName: String
    let matchingNotes: [String]
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
}

extension PerfumeRecommendation {
    init(response: PerfumeRecommendationResponse) {
        self.id = response.id
        self.perfumeName = response.perfumeName
        self.brandName = response.brandName
        self.matchingNotes = response.matchingNotes
        self.matchPercentage = response.matchPercentage
        self.longevityScore = response.longevityScore
        self.sillageScore = response.sillageScore
    }
}
