//
//  PerfumeRecommendationsViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Combine
import Observation

@Observable final class PerfumeRecommendationsViewModel {
    let selectedPerfumes: [SearchPerfumeItem]
    var perfumeRecommendations: [PerfumeRecommendation] = []
    var isLoading = false
    var errorMessage: String?

    init(selectedPerfumes: [SearchPerfumeItem]) {
        self.selectedPerfumes = selectedPerfumes
    }
}
