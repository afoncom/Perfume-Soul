//
//  ListPerfume.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct ListPerfume {
    let id: UUID
    let perfumeName: String
    let brandName: String
    let accords: [String]
    let matchingNotes: [String]
    let matchPercentage: Int
    let imageUrl: String
}

extension ListPerfume {
    init(response: ListPerfumeResponse) {
        self.id = response.id
        self.perfumeName = response.perfumeName
        self.brandName = response.brandName
        self.accords = response.accords
        self.matchingNotes = response.matchingNotes
        self.matchPercentage = response.matchPercentage
        self.imageUrl = response.imageUrl
    }
}
