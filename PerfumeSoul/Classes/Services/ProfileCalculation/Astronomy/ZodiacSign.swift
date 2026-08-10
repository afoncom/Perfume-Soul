//
//  ZodiacSign.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.07.2026.
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
}

enum ZodiacElement: Hashable {
    case fire
    case earth
    case air
    case water
}
