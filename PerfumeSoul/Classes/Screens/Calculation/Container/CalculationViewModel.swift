//
//  CalculationViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import MapKit
import Observation

@Observable final class CalculationViewModel {
    var firstName = ""
    var birthDate = Date()
    var birthTime = CalculationViewModel.defaultBirthTime
    var birthPlace = ""
    var selectedBirthPlace: BirthPlaceSelection?
    var birthPlaceCompletions: [MKLocalSearchCompletion] = []

    var isContinueEnabled: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedBirthPlace != nil
    }

    var formattedBirthDate: String {
        Self.birthDateFormatter.string(from: birthDate)
    }
    
    var formattedBirthTime: String {
        Self.birthTimeFormatter.string(from: birthTime)
    }
    
    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private static let birthTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static let defaultBirthTime: Date = {
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
