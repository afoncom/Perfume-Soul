//
//  PerfumeDetailsResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation

struct PerfumeDetailsResponse: Decodable {
    let id: Int
    let brand: String
    let perfumeName: String
    let longevityScore: Int?
    let sillageScore: Int?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}
