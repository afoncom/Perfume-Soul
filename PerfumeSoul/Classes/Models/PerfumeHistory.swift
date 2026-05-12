//
//  PerfumeHistory.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct PerfumeHistory {
    let year: Int
    let perfumeName: String
    let shortStory: String
    let fullStory: String
    let imageUrl: String
}

extension PerfumeHistory {
    init(responce: PerfumeHistoryResponse) {
        self.year = responce.year
        self.perfumeName = responce.perfumeName
        self.shortStory = responce.fullStory
        self.fullStory = responce.fullStory
        self.imageUrl = responce.imageUrl
    }
}
