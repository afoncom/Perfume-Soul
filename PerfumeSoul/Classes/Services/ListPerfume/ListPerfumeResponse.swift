//
//  ListPerfumeResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct ListPerfumeResponse: Decodable {
    let id: UUID
    let perfumeName: String
    let brandName: String
    let accords: [String]
    let matchingNotes: [String]
    let matchPercentage: Int
    let imageUrl: String
}
