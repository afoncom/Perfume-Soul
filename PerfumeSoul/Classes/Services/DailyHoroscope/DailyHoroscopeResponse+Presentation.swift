//
//  DailyHoroscopeResponse+Presentation.swift
//  PerfumeSoul
//
//  Created by Codex on 06.05.2026.
//

import SwiftUI

extension DailyHoroscopeResponse {
    var displayName: String {
        switch sign {
        case "aries":
            return L10n.Horoscope.Sign.aries
        case "taurus":
            return L10n.Horoscope.Sign.taurus
        case "gemini":
            return L10n.Horoscope.Sign.gemini
        case "cancer":
            return L10n.Horoscope.Sign.cancer
        case "leo":
            return L10n.Horoscope.Sign.leo
        case "virgo":
            return L10n.Horoscope.Sign.virgo
        case "libra":
            return L10n.Horoscope.Sign.libra
        case "scorpio":
            return L10n.Horoscope.Sign.scorpio
        case "sagittarius":
            return L10n.Horoscope.Sign.sagittarius
        case "capricorn":
            return L10n.Horoscope.Sign.capricorn
        case "aquarius":
            return L10n.Horoscope.Sign.aquarius
        case "pisces":
            return L10n.Horoscope.Sign.pisces
        default:
            return sign.capitalized
        }
    }
    
    var symbol: String {
        switch sign {
        case "aries":
            return "♈"
        case "taurus":
            return "♉"
        case "gemini":
            return "♊"
        case "cancer":
            return "♋"
        case "leo":
            return "♌"
        case "virgo":
            return "♍"
        case "libra":
            return "♎"
        case "scorpio":
            return "♏"
        case "sagittarius":
            return "♐"
        case "capricorn":
            return "♑"
        case "aquarius":
            return "♒"
        case "pisces":
            return "♓"
        default:
            return "✦"
        }
    }
    
    var iconColor: Color {
        switch sign {
        case "aries":
            Color(.pinkButton)
        case "taurus":
            Color(.zodiacMint)
        case "gemini":
            Color(.zodiacOrange)
        case "cancer":
            Color(.zodiacBlue).opacity(0.7)
        case "leo":
            Color(.zodiacOrange).opacity(0.85)
        case "virgo":
            Color(.zodiacBrown).opacity(0.7)
        case "libra":
            Color(.zodiacPink).opacity(0.75)
        case "scorpio":
            Color(.pinkButton)
        case "sagittarius":
            Color(.zodiacPurple).opacity(0.75)
        case "capricorn":
            Color(.zodiacGray).opacity(0.85)
        case "aquarius":
            Color(.zodiacCyan).opacity(0.8)
        case "pisces":
            Color(.zodiacBlue).opacity(0.55)
        default:
            Color(.textSecondary)
        }
    }
}
