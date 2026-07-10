//
//  Profile.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import Foundation

struct Profile: Equatable {
    let name: String
    let birthDate: String
    let birthTime: String
    let birthPlace: String
    let birthLatitude: Double?
    let birthLongitude: Double?
    let birthTimeZoneIdentifier: String?
}

extension Profile: DatabaseStorable {
    init?(storableModel: CDProfile) {
        self.name = storableModel.name ?? ""
        self.birthDate = storableModel.birthDate ?? ""
        self.birthTime = storableModel.birthTime ?? ""
        self.birthPlace = storableModel.birthPlace ?? ""
        self.birthLatitude = Double(storableModel.birthLatitude ?? "")
        self.birthLongitude = Double(storableModel.birthLongitude ?? "")
        self.birthTimeZoneIdentifier = storableModel.birthTimeZoneIdentifier
    }
}

extension CDProfile: CDModel {
    func update(by model: Profile) {
        self.name = model.name
        self.birthDate = model.birthDate
        self.birthTime = model.birthTime
        self.birthPlace = model.birthPlace
        self.birthLatitude = model.birthLatitude.map(String.init)
        self.birthLongitude = model.birthLongitude.map(String.init)
        self.birthTimeZoneIdentifier = model.birthTimeZoneIdentifier
    }
}

extension Profile {
    var hasCompleteBirthPlaceData: Bool {
        birthLatitude != nil &&
        birthLongitude != nil &&
        birthTimeZoneIdentifier?.isEmpty == false
    }

    var normalizedBirthDate: String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: birthDate) else {
            return nil
        }

        return outputFormatter.string(from: date)
    }

    func zodiacSign() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let date = formatter.date(from: birthDate) else {
            return nil
        }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "aries"
        case (4, 20...30), (5, 1...20): return "taurus"
        case (5, 21...31), (6, 1...20): return "gemini"
        case (6, 21...30), (7, 1...22): return "cancer"
        case (7, 23...31), (8, 1...22): return "leo"
        case (8, 23...31), (9, 1...22): return "virgo"
        case (9, 23...30), (10, 1...22): return "libra"
        case (10, 23...31), (11, 1...21): return "scorpio"
        case (11, 22...30), (12, 1...21): return "sagittarius"
        case (12, 22...31), (1, 1...19): return "capricorn"
        case (1, 20...31), (2, 1...18): return "aquarius"
        case (2, 19...29), (3, 1...20): return "pisces"
        default: return nil
        }
    }
}
