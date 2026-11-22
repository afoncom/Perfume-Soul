//
//  DailyHoroscopeRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct DailyHoroscopeRequest: Request {
    let path: String = "/horoscope/daily"
    let httpMethod: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "timeZone", value: TimeZone.current.identifier)]
    }
}
