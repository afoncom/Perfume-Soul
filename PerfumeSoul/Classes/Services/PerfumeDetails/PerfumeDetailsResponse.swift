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

    private enum CodingKeys: String, CodingKey {
        case id
        case brand
        case perfumeName
        case concentration
        case fragranceFamily
        case seasonProfile
        case occasionProfile
        case styleProfile
        case genderProfile
        case moodProfile
        case longevityScore
        case sillageScore
        case accords
        case topNotes
        case middleNotes
        case baseNotes
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.brand = try container.decode(String.self, forKey: .brand)
        self.perfumeName = try container.decode(String.self, forKey: .perfumeName)
        self.concentration = try container.decodeIfPresent(String.self, forKey: .concentration)
        self.fragranceFamily = try container.decodeIfPresent(String.self, forKey: .fragranceFamily)
        self.seasonProfile = try container.decodeIfPresent(String.self, forKey: .seasonProfile)
        self.occasionProfile = try container.decodeIfPresent(String.self, forKey: .occasionProfile)
        self.styleProfile = try container.decodeIfPresent(String.self, forKey: .styleProfile)
        self.genderProfile = try container.decodeIfPresent(String.self, forKey: .genderProfile)
        self.moodProfile = try container.decodeIfPresent(String.self, forKey: .moodProfile)
        self.longevityScore = try container.decodeIfPresent(Int.self, forKey: .longevityScore)
        self.sillageScore = try container.decodeIfPresent(Int.self, forKey: .sillageScore)
        self.accords = try container.decodeIfPresent([PerfumeAccordResponse].self, forKey: .accords) ?? []
        self.topNotes = try container.decode([String].self, forKey: .topNotes)
        self.middleNotes = try container.decode([String].self, forKey: .middleNotes)
        self.baseNotes = try container.decode([String].self, forKey: .baseNotes)
    }
}

struct PerfumeAccordResponse: Decodable {
    let name: String
    let weight: Double
}
