//
//  DailyPerfumeState.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct DailyPerfumeSummary: Codable, Equatable, Identifiable {
    let id: Int
    let perfumeName: String
    let brandName: String
}

enum DailyPerfumeReaction: String, Codable, Equatable {
    case pending
    case saved
    case dismissed
}

struct DailyPerfumeState: Codable, Equatable {
    var profileCalculationCacheKey: String?
    var dayKey: String
    var currentPerfume: DailyPerfumeSummary?
    var currentReaction: DailyPerfumeReaction?
    var shownPerfumeIDs: [Int]
    var savedPerfumes: [DailyPerfumeSummary]
    var dislikedPerfumeIDs: [Int]
    var lastShownBrand: String?
}
