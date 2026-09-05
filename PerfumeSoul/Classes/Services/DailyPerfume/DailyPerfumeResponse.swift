//
//  DailyPerfumeResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct DailyPerfumeCandidateResponse: Decodable, Equatable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let natalScore: Double
}
