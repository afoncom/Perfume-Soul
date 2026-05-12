//
//  PerfumeHistoryResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 03.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct PerfumeHistoryResponse: Decodable {
    let year: Int
    let perfumeName: String
    let shortStory: String
    let fullStory: String
    let imageUrl: String
}
