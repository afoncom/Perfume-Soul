//
//  ComparePerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct ComparePerfumeRequest: Request {
    let perfumeID: Int
    let httpMethod: HTTPMethod = .get

    var path: String {
        "/perfumes/\(perfumeID)/notes"
    }
}
