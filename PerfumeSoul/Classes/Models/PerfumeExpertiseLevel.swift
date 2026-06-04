//
//  PerfumeExpertiseLevel.swift
//  PerfumeSoul
//
//  Created by afon.com on 04.06.2026.
//

import Foundation

enum PerfumeExpertiseLevel {
    case novice
    case noteExplorer
    case accordExpert
    case fragranceAnalyst
    case perfumer

    var range: ClosedRange<Int> {
        switch self {
        case .novice:
            return 0...9
        case .noteExplorer:
            return 10...24
        case .accordExpert:
            return 25...49
        case .fragranceAnalyst:
            return 50...99
        case .perfumer:
            return 100...Int.max
        }
    }

    var nextLevelStart: Int? {
        switch self {
        case .novice:
            return 10
        case .noteExplorer:
            return 25
        case .accordExpert:
            return 50
        case .fragranceAnalyst:
            return 100
        case .perfumer:
            return nil
        }
    }

    static func level(for correctAnswers: Int) -> PerfumeExpertiseLevel {
        switch correctAnswers {
        case ..<10:
            return .novice
        case 10..<25:
            return .noteExplorer
        case 25..<50:
            return .accordExpert
        case 50..<100:
            return .fragranceAnalyst
        default:
            return .perfumer
        }
    }
}
