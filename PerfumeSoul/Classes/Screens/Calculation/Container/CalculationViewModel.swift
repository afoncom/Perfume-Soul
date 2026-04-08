//
//  CalculationViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

@Observable final class CalculationViewModel {
    var firstName = ""
    var birthDate = Date()
    var birthTime = CalculationViewModel.defaultBirthTime
    var birthPlace = ""

    var formattedBirthDate: String {
        Self.birthDateFormatter.string(from: birthDate)
    }
    
    var formattedBirthTime: String {
        Self.birthTimeFormatter.string(from: birthTime)
    }
    
    static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static let birthTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let defaultBirthTime: Date = {
        let calendar = Calendar.current
        let date = Date()
        return calendar.date(
            bySettingHour: 12,
            minute: 0,
            second: 0,
            of: date
        ) ?? date
    }()
}
