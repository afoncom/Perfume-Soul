//
//  PerfumeHistoryResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 03.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct PerfumeHistoryResponse: Decodable {
    let publicationDate: String
    let eventYear: Int
    let title: String
    let fullStory: String
}
