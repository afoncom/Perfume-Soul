//
//  PerfumeDetails.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation

struct PerfumeAccord {
    let name: String
    let weight: Double
}

struct PerfumeDetails {
    let id: Int
    let brand: String
    let name: String
    let concentration: String?
    let fragranceFamily: String?
    let seasonProfile: String?
    let occasionProfile: String?
    let styleProfile: String?
    let genderProfile: String?
    let moodProfile: String?
    let longevityScore: Int?
    let sillageScore: Int?
    let accords: [PerfumeAccord]
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}

extension PerfumeDetails {
    init(response: PerfumeDetailsResponse) {
        self.id = response.id
        self.brand = response.brand
        self.name = response.perfumeName
        self.concentration = response.concentration
        self.fragranceFamily = response.fragranceFamily
        self.seasonProfile = response.seasonProfile
        self.occasionProfile = response.occasionProfile
        self.styleProfile = response.styleProfile
        self.genderProfile = response.genderProfile
        self.moodProfile = response.moodProfile
        self.longevityScore = response.longevityScore
        self.sillageScore = response.sillageScore
        self.accords = response.accords.map {
            PerfumeAccord(
                name: $0.name,
                weight: $0.weight
            )
        }
        self.topNotes = response.topNotes
        self.middleNotes = response.middleNotes
        self.baseNotes = response.baseNotes
    }
}
