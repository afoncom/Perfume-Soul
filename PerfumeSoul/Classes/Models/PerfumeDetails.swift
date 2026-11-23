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
    let releaseYear: Int?
    let perfumer: String?
    let shortDescription: String?
    let recommendationReason: String?
    let fullStory: String?
    let accords: [PerfumeAccord]
    let notesLanguage: String?
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
    let imageURL: URL?
}

extension PerfumeDetails {
    init(
        response: PerfumeDetailsResponse,
        languageCode: String = SupportedAppLanguage.currentCode,
        bundle: Bundle = .main
    ) {
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
        self.releaseYear = response.releaseYear
        self.perfumer = response.perfumer
        self.shortDescription = response.shortDescription
        self.recommendationReason = response.recommendationReason
        self.fullStory = response.fullStory
        self.accords = response.accords.map {
            PerfumeAccord(
                name: $0.name,
                weight: $0.weight
            )
        }
        self.notesLanguage = response.notesLanguage
        self.topNotes = PerfumeNoteFormatter.names(keys: response.topNoteKeys, fallbackNames: response.topNotes, languageCode: languageCode, bundle: bundle)
        self.middleNotes = PerfumeNoteFormatter.names(keys: response.middleNoteKeys, fallbackNames: response.middleNotes, languageCode: languageCode, bundle: bundle)
        self.baseNotes = PerfumeNoteFormatter.names(keys: response.baseNoteKeys, fallbackNames: response.baseNotes, languageCode: languageCode, bundle: bundle)
        self.imageURL = response.imageURL.flatMap(URL.init(string:))
    }
}
