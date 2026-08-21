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
    var selectedBirthPlace: BirthPlaceSelection?
    var isSearchingBirthPlace = false
    var activeBirthPlaceSearchQuery = ""
    var birthPlaceSuggestions: [BirthPlaceSuggestion] = []
    var birthPlaceErrorMessage: String?

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

    init() {
    }

    init(initialProfile: Profile) {
        firstName = initialProfile.name
        birthPlace = initialProfile.birthPlace

        if let birthDate = Self.birthDateFormatter.date(from: initialProfile.birthDate) {
            self.birthDate = birthDate
        }

        if let birthTime = Self.birthTimeFormatter.date(from: initialProfile.birthTime) {
            self.birthTime = birthTime
        }

        if
            let latitude = initialProfile.birthLatitude,
            let longitude = initialProfile.birthLongitude,
            let timeZoneIdentifier = initialProfile.birthTimeZoneIdentifier,
            !timeZoneIdentifier.isEmpty
        {
            selectedBirthPlace = BirthPlaceSelection(
                displayName: initialProfile.birthPlace,
                latitude: latitude,
                longitude: longitude,
                timeZoneIdentifier: timeZoneIdentifier
            )
        }
    }
    
    private static let birthDateFormatter: DateFormatter = {
        FixedFormatDateFormatter.make(dateFormat: "dd.MM.yyyy")
    }()
    
    private static let birthTimeFormatter: DateFormatter = {
        FixedFormatDateFormatter.make(dateFormat: "HH:mm")
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
