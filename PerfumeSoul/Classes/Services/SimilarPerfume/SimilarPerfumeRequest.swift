//
//  SimilarPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct SimilarPerfumeRequest: Request {
    let path: String = "/similar/perfume"
    let httpMethod: HTTPMethod = .get
}
