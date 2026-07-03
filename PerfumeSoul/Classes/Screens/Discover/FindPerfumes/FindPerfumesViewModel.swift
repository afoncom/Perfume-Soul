//
//  FindPerfumesViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Combine
import Observation

enum FindPerfumeField: Hashable {
    case first
    case second
    case third
}

@Observable final class FindPerfumesViewModel {
    var firstSearchText = ""
    var secondSearchText = ""
    var thirdSearchText = ""
    var firstSelectedPerfume: SearchPerfumeItem?
    var secondSelectedPerfume: SearchPerfumeItem?
    var thirdSelectedPerfume: SearchPerfumeItem?
    var searchResults: [SearchPerfumeItem] = []
    var isSearching = false
    var searchErrorMessage: String?
    var validationMessage: String?
    var isShowingValidationAlert = false

    var selectedPerfumes: [SearchPerfumeItem] {
        [
            firstSelectedPerfume,
            secondSelectedPerfume,
            thirdSelectedPerfume
        ]
        .compactMap { $0 }
    }
}
