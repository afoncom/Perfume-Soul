//
//  PerfumeHistory.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct PerfumeHistory {
    let publicationDate: String
    let year: Int
    let title: String
    let fullStory: String

    var eventDateText: String {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.timeZone = TimeZone(secondsFromGMT: 0)
        input.dateFormat = "yyyy-MM-dd"

        guard let date = input.date(from: publicationDate) else {
            return "\(publicationDate) \(year)"
        }

        let output = DateFormatter()
        output.locale = Locale(identifier: SupportedAppLanguage.currentCode)
        output.timeZone = TimeZone(secondsFromGMT: 0)
        output.dateFormat = "d MMMM"
        return "\(output.string(from: date)) \(year)"
    }
}

extension PerfumeHistory {
    init(responce: PerfumeHistoryResponse) {
        self.publicationDate = responce.publicationDate
        self.year = responce.eventYear
        self.title = responce.title
        self.fullStory = responce.fullStory
    }
}
