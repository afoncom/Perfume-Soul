//
//  ComparePerfumeResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct ComparePerfumeResponse: Decodable {
    let id: Int
    let brand: String
    let perfumeName: String
    let topNotes: [String]
    let middleNotes: [String]
    let baseNotes: [String]
}
