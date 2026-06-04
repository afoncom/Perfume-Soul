//
//  PerfumeExpertiseLevel.swift
//  PerfumeSoul
//
//  Created by afon.com on 04.06.2026.
//

import Foundation

enum PerfumeExpertiseLevel: CaseIterable {
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
        guard
            let currentIndex = Self.allCases.firstIndex(of: self),
            Self.allCases.indices.contains(currentIndex + 1)
        else {
            return nil
        }

        return Self.allCases[currentIndex + 1].range.lowerBound
    }

    static func level(for correctAnswers: Int) -> PerfumeExpertiseLevel {
        allCases.first(where: { $0.range.contains(correctAnswers) }) ?? .perfumer
    }
}
