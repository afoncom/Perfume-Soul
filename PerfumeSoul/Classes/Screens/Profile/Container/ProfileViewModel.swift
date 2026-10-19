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
    case invalidBirthData
    case failed
}

@Observable final class ProfileViewModel {
    var profile: Profile?
    var avatar: ProfileAvatar = .placeholder
    var profileCalculationState: ProfileCalculationState = .idle
    var isShowingDeleteProfileAlert = false
    var totalCorrectQuizAnswers = 0

    var birthInfo: String {
        guard let profile else {
            return ""
        }
        return [profile.birthDate, profile.birthTime, profile.birthPlace]
            .filter { !$0.isEmpty }.joined(separator: " · ")
    }

    var natalRows: [(title: String, value: String)] {
        guard let chart = profileCalculation?.natalChart else {
            return []
        }
        return [
            (L10n.Profile.NatalChart.sun, chart.sun),
            (L10n.Profile.NatalChart.moon, chart.moon),
            (L10n.Profile.NatalChart.ascendant, chart.ascendant)
        ].map { ($0.0, DailyHoroscope(sign: $0.1.sign.rawValue, energyOfDay: "").displayName) }
    }

    var elementRows: [(title: String, value: Int)] {
        guard let balance = profileCalculation?.elementBalance else {
            return []
        }
        return [
            (L10n.Profile.Element.fire, balance.fire),
            (L10n.Profile.Element.earth, balance.earth),
            (L10n.Profile.Element.air, balance.air),
            (L10n.Profile.Element.water, balance.water)
        ]
        .filter { $0.1 > 0 }
    }

    var expertiseTitle: String {
        switch perfumeExpertiseLevel {
        case .novice: return L10n.Profile.Expertise.Level.novice
        case .noteExplorer: return L10n.Profile.Expertise.Level.noteExplorer
        case .accordExpert: return L10n.Profile.Expertise.Level.accordExpert
        case .fragranceAnalyst: return L10n.Profile.Expertise.Level.fragranceAnalyst
        case .perfumer: return L10n.Profile.Expertise.Level.perfumer
        }
    }

    var expertiseProgressText: String {
        let next = answersToNextLevel.map { L10n.Profile.Expertise.nextLevelFormat($0) }
            ?? L10n.Profile.Expertise.maxLevel
        return L10n.Profile.Expertise.correctAnswersFormat(totalCorrectQuizAnswers) + " · " + next
    }

    var calculationMessage: String {
        switch profileCalculationState {
        case .missingBirthPlaceData: return L10n.Profile.Calculation.MissingBirthData.subtitle
        case .invalidBirthData: return L10n.Profile.Calculation.InvalidBirthData.subtitle
        default: return L10n.Profile.Calculation.Failed.subtitle
        }
    }

    var calculationActionTitle: String {
        switch profileCalculationState {
        case .missingBirthPlaceData: return L10n.Profile.Calculation.MissingBirthData.button
        case .invalidBirthData: return L10n.Profile.Calculation.InvalidBirthData.button
        default: return L10n.Profile.Calculation.Failed.button
        }
    }

    var profileCalculation: ProfileCalculation? {
        guard case let .loaded(profileCalculation) = profileCalculationState else {
            return nil
        }

        return profileCalculation
    }

    var isProfileCalculationLoading: Bool {
        profileCalculationState == .loading
    }

    var didFailProfileCalculation: Bool {
        profileCalculationState == .failed
    }

    var needsBirthDataForProfileCalculation: Bool {
        switch profileCalculationState {
        case .missingBirthPlaceData, .invalidBirthData:
            return true
        case .idle, .loading, .loaded, .failed:
            return false
        }
    }

    var needsProfileCalculationAction: Bool {
        switch profileCalculationState {
        case .missingBirthPlaceData, .invalidBirthData, .failed:
            return true
        case .idle, .loading, .loaded:
            return false
        }
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
