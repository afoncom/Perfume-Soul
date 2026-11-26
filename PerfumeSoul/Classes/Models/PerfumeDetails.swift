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
    // Nil for legacy responses; otherwise the actual language of each rendered note.
    var resolvedNoteLanguages: [String?]?
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
        func resolve(
            items: [PerfumeDetailsResponse.Note]?,
            keys: [String]?,
            names: [String]
        ) -> [PerfumeNoteFormatter.LocalizedNote] {
            if let items {
                return items.compactMap {
                    PerfumeNoteFormatter.localizedNote(
                        key: $0.key,
                        fallbackName: $0.name,
                        fallbackLanguage: $0.language,
                        languageCode: languageCode,
                        bundle: bundle
                    )
                }
            }
            let entries: [(String?, String)]
            if let keys, !keys.isEmpty {
                entries = keys.enumerated().map { index, key in
                    (key, names.indices.contains(index) ? names[index] : "")
                }
            } else {
                entries = names.map { (nil, $0) }
            }
            return entries.compactMap { key, name in
                PerfumeNoteFormatter.localizedNote(
                    key: key,
                    fallbackName: name,
                    fallbackLanguage: response.notesLanguage,
                    languageCode: languageCode,
                    bundle: bundle
                )
            }
        }
        let top = resolve(items: response.topNoteItems, keys: response.topNoteKeys, names: response.topNotes)
        let middle = resolve(items: response.middleNoteItems, keys: response.middleNoteKeys, names: response.middleNotes)
        let base = resolve(items: response.baseNoteItems, keys: response.baseNoteKeys, names: response.baseNotes)
        self.topNotes = PerfumeNoteFormatter.names(top.map(\.name))
        self.middleNotes = PerfumeNoteFormatter.names(middle.map(\.name))
        self.baseNotes = PerfumeNoteFormatter.names(base.map(\.name))
        let hasNoteMetadata = [response.topNoteItems, response.middleNoteItems, response.baseNoteItems]
            .contains { $0 != nil }
            || [response.topNoteKeys, response.middleNoteKeys, response.baseNoteKeys].contains { $0?.isEmpty == false }
        if hasNoteMetadata {
            self.resolvedNoteLanguages = (top + middle + base).map(\.language)
        }
        self.imageURL = response.imageURL.flatMap(URL.init(string:))
    }
}
