//
//  ProfileDescriptionViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

struct NatalPlacementSummary: Identifiable {
    let id: String
    let title: String
    let sign: String
}

enum ProfileDescriptionScreenState: Equatable {
    case idle
    case loading
    case content(ProfileCalculation, ProfileDescription)
    case missingBirthPlaceData
    case invalidBirthData
    case failed
}

@Observable final class ProfileDescriptionViewModel {
    var profile: Profile?
    var state: ProfileDescriptionScreenState = .idle

    var profileCalculation: ProfileCalculation? {
        guard case let .content(profileCalculation, _) = state else {
            return nil
        }

        return profileCalculation
    }

    var profileDescription: ProfileDescription? {
        guard case let .content(_, profileDescription) = state else {
            return nil
        }

        return profileDescription
    }

    var canContinue: Bool {
        profileCalculation != nil
    }

    var placements: [NatalPlacementSummary] {
        guard let chart = profileCalculation?.natalChart else {
            return []
        }
        return [
            placement("sun", title: L10n.Profile.NatalChart.sun, sign: chart.sun.sign),
            placement("moon", title: L10n.Profile.NatalChart.moon, sign: chart.moon.sign),
            placement("ascendant", title: L10n.Profile.NatalChart.ascendant, sign: chart.ascendant.sign)
        ]
    }

    private func placement(_ id: String, title: String, sign: ZodiacSign) -> NatalPlacementSummary {
        NatalPlacementSummary(
            id: id,
            title: title,
            sign: Bundle.main.localizedString(forKey: "horoscope.sign.\(sign.rawValue)", value: nil, table: nil)
        )
    }
}

extension ProfileDescriptionViewModel {
    func insightCategory(for style: ProfileDescriptionInsightStyle) -> String {
        switch style {
        case .sun: L10n.PerfumeFlow.personality
        case .moon: L10n.PerfumeFlow.emotions
        case .ascendant: L10n.PerfumeFlow.firstImpression
        case .dominantElement: L10n.PerfumeFlow.strength
        case .weakElement: L10n.PerfumeFlow.balance
        case .synthesis: L10n.PerfumeFlow.overview
        }
    }
}
