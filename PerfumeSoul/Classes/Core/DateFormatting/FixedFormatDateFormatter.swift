//
//  FixedFormatDateFormatter.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.07.2026.
//

import Foundation

enum FixedFormatDateFormatter {
    static func make(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = dateFormat
        return formatter
    }
}
