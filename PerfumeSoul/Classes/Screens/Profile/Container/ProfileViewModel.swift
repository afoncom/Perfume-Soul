//
//  ProfileViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

@Observable final class ProfileViewModel {
    var profile: Profile?
    var isShowingDeleteProfileAlert = false
    var totalCorrectQuizAnswers = 18

    var perfumeExpertiseLevel: PerfumeExpertiseLevel {
        PerfumeExpertiseLevel.level(for: totalCorrectQuizAnswers)
    }

    var answersToNextLevel: Int? {
        perfumeExpertiseLevel.nextLevelStart.map { max($0 - totalCorrectQuizAnswers, 0) }
    }

    var perfumeExpertiseProgress: Double {
        let lowerBound = perfumeExpertiseLevel.range.lowerBound
        let upperBound = perfumeExpertiseLevel.nextLevelStart ?? perfumeExpertiseLevel.range.upperBound

        guard upperBound > lowerBound else { return 1 }
        let progress = Double(totalCorrectQuizAnswers - lowerBound) / Double(upperBound - lowerBound)
        return min(max(progress, 0), 1)
    }
}

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
