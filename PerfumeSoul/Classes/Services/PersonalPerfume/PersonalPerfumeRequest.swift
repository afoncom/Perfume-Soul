//
//  PersonalPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by Codex on 18.07.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PersonalPerfumeRequest: Request {
    let profile: PersonalPerfumeProfileRequest
    let path: String = "/personal-perfumes"
    let httpMethod: HTTPMethod = .post

    var httpBody: Data? {
        try? JSONEncoder().encode(profile)
    }
}

struct PersonalPerfumeProfileRequest: Encodable {
    let sun: String
    let moon: String
    let ascendant: String
    let elementBalance: PersonalPerfumeElementBalanceRequest
}

struct PersonalPerfumeElementBalanceRequest: Encodable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}
