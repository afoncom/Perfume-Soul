//
//  PersonalPerfumeResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 18.07.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PersonalPerfumeResponse: Decodable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let marketSegment: PersonalPerfumeMarketSegment
    let matchPercentage: Int
    let longevityScore: Int?
    let sillageScore: Int?
    var matchingNoteKeys: [String]?

    var matchingNotes: [String] {
        localizedMatchingNotes()
    }
    func localizedMatchingNotes(
        languageCode: String = SupportedAppLanguage.currentCode,
        bundle: Bundle = .main
    ) -> [String] {
        PerfumeNoteFormatter.names(keys: matchingNoteKeys, fallbackNames: [], languageCode: languageCode, bundle: bundle)
    }
}

enum PersonalPerfumeMarketSegment: String, Decodable, CaseIterable {
    case luxury
    case daily
    case niche
}
