//
//  ComparePerfume.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct ComparePerfume {
    let id: Int
    let brand: String
    let name: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}

extension ComparePerfume {
    init(response: ComparePerfumeResponse) {
        self.id = response.id
        self.brand = response.brand
        self.name = response.perfumeName
        self.longevityScore = response.longevityScore
        self.sillageScore = response.sillageScore
        self.topNotes = response.topNotes
        self.middleNotes = response.middleNotes
        self.baseNotes = response.baseNotes
    }
}
