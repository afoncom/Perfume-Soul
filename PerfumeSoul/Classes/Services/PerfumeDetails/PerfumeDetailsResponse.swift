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
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let longevityScore: Int?
    let sillageScore: Int?
    let accords: [PerfumeAccordResponse]
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}

struct PerfumeAccordResponse: Decodable {
    let name: String
    let weight: Double
}
