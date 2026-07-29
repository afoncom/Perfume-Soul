//
//  PersonalPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

enum PersonalPerfumeScreenState {
    case loading
    case content([PersonalPerfumeSection])
    case empty
    case missingProfileCalculation
    case requestFailed
}

@Observable final class PersonalPerfumeViewModel {
    var state: PersonalPerfumeScreenState = .loading

    var canContinue: Bool {
        switch state {
        case .content, .empty:
            return true
        case .loading, .missingProfileCalculation, .requestFailed:
            return false
        }
    }
}
