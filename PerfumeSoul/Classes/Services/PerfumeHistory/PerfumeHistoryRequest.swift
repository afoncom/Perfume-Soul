//
//  PerfumeHistoryRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PerfumeHistoryRequest: Request {
    let timeZoneIdentifier: String
    let path: String = "/perfumery-history"
    let httpMethod: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "timeZone", value: timeZoneIdentifier)]
    }

    init(timeZoneIdentifier: String = TimeZone.current.identifier) {
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}
