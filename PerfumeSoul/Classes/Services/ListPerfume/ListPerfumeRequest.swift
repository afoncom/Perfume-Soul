//
//  ListPerfumeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 13.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct ListPerfumeRequest: Request {
    let path: String = "/list/perfume"
    let httpMethod: HTTPMethod = .get
}
