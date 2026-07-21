//
//  ProfileViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

enum ProfileCalculationState: Equatable {
    case idle
    case loading
    case loaded(ProfileCalculation)
    case missingBirthPlaceData
    case failed
}

@Observable final class ProfileViewModel {
    var profile: Profile?
    var profileCalculationState: ProfileCalculationState = .idle
    var isShowingDeleteProfileAlert = false
    var totalCorrectQuizAnswers = 0

    var profileCalculation: ProfileCalculation? {
        guard case let .loaded(profileCalculation) = profileCalculationState else {
            return nil
        }

        return profileCalculation
    }

    var perfumeExpertiseLevel: PerfumeExpertiseLevel {
        PerfumeExpertiseLevel.level(for: totalCorrectQuizAnswers)
    }

    var answersToNextLevel: Int? {
        perfumeExpertiseLevel.nextLevelStart.map { max($0 - totalCorrectQuizAnswers, 0) }
    }

    var perfumeExpertiseProgress: Double {
        let lowerBound = perfumeExpertiseLevel.range.lowerBound
        let upperBound = perfumeExpertiseLevel.nextLevelStart ?? perfumeExpertiseLevel.range.upperBound

        guard upperBound > lowerBound else {
            return 1
        }

        let progress = Double(totalCorrectQuizAnswers - lowerBound) / Double(upperBound - lowerBound)
        return min(max(progress, 0), 1)
    }
}
