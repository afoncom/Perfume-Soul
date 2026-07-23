//
//  PersonalPerfumeResponse.swift
//  PerfumeSoul
//
//  Created by Codex on 18.07.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PersonalPerfumeResponse: Decodable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let marketSegment: PersonalPerfumeMarketSegment
    let matchingNoteKeys: [String]
    let matchingAccordKeys: [String]
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
}

enum PersonalPerfumeMarketSegment: String, Decodable, CaseIterable {
    case luxury
    case daily
    case niche
}
