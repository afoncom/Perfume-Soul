//
//  ComparePerfumesViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

enum ComparePerfumeField: Hashable {
    case left
    case right
}

@Observable final class ComparePerfumesViewModel {
    var leftSearchText = ""
    var rightSearchText = ""
    var leftSelectedPerfume: SearchPerfumeItem?
    var rightSelectedPerfume: SearchPerfumeItem?
    var activeField: ComparePerfumeField = .left
    var searchResults: [SearchPerfumeItem] = []
    var isSearching = false
    var searchErrorMessage: String?
    var validationMessage: String?
    var isShowingValidationAlert = false
    var leftPerfume: ComparePerfume?
    var rightPerfume: ComparePerfume?
    var isLoading = false
    var hasLoadedOnce = false
    var errorMessage: String?

    var hasComparison: Bool {
        leftPerfume != nil && rightPerfume != nil
    }
}
