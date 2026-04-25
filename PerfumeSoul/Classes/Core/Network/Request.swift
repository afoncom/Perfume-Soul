//
//  Request.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol Request {
    var path: String { get }
    var httpMethod: String { get }
}
