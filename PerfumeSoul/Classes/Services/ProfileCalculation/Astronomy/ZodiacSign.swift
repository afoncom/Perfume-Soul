//
//  ZodiacSign.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

enum ZodiacSign: String, CaseIterable, Codable, Equatable, Hashable {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    init(longitude: Double) {
        let normalizedLongitude = Self.normalize(longitude)

        switch Int(normalizedLongitude / 30.0) {
        case 0: self = .aries
        case 1: self = .taurus
        case 2: self = .gemini
        case 3: self = .cancer
        case 4: self = .leo
        case 5: self = .virgo
        case 6: self = .libra
        case 7: self = .scorpio
        case 8: self = .sagittarius
        case 9: self = .capricorn
        case 10: self = .aquarius
        default: self = .pisces
        }
    }

    var element: ZodiacElement {
        switch self {
        case .aries, .leo, .sagittarius:
            .fire
        case .taurus, .virgo, .capricorn:
            .earth
        case .gemini, .libra, .aquarius:
            .air
        case .cancer, .scorpio, .pisces:
            .water
        }
    }

    private static func normalize(_ longitude: Double) -> Double {
        let remainder = longitude.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }
}

enum ZodiacElement: Hashable {
    case fire
    case earth
    case air
    case water
}
