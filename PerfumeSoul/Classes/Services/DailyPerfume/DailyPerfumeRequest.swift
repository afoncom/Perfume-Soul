//
//  DailyPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct DailyPerfumeRequest: Request {
    let profile: DailyPerfumeProfileRequest
    let excludedPerfumeIDs: [Int]
    let lastShownBrand: String?
    let limit: Int
    let path: String = "/daily-perfume/candidates"
    let httpMethod: HTTPMethod = .post

    var httpBody: Data? {
        try? JSONEncoder().encode(
            DailyPerfumeRequestBody(
                sun: profile.sun,
                moon: profile.moon,
                ascendant: profile.ascendant,
                elementBalance: profile.elementBalance,
                excludedPerfumeIDs: excludedPerfumeIDs,
                lastShownBrand: lastShownBrand,
                limit: limit
            )
        )
    }
}

struct DailyPerfumeProfileRequest: Encodable, Equatable {
    let sun: String
    let moon: String
    let ascendant: String
    let elementBalance: DailyPerfumeElementBalanceRequest
}

struct DailyPerfumeElementBalanceRequest: Encodable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}

private struct DailyPerfumeRequestBody: Encodable {
    let sun: String
    let moon: String
    let ascendant: String
    let elementBalance: DailyPerfumeElementBalanceRequest
    let excludedPerfumeIDs: [Int]
    let lastShownBrand: String?
    let limit: Int
}
