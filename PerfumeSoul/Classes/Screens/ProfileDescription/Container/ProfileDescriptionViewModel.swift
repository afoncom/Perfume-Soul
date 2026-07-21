//
//  ProfileDescriptionViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

enum ProfileDescriptionScreenState: Equatable {
    case idle
    case loading
    case content(ProfileCalculation, ProfileDescription)
    case missingBirthPlaceData
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
}
