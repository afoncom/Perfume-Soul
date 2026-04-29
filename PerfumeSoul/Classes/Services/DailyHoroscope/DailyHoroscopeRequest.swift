//
//  DailyHoroscopeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct DailyHoroscopeRequest: Request {
    let path: String = "/horoscope/daily"
    let httpMethod: HTTPMethod = .get
}
