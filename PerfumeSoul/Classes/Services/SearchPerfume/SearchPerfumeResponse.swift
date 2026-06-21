//
//  SearchPerfumeResponse.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct SearchPerfumePageResponse: Decodable {
    let items: [SearchPerfumeResponse]
    let hasMore: Bool
}

struct SearchPerfumeResponse: Decodable {
    let id: Int
    let name: String
}
