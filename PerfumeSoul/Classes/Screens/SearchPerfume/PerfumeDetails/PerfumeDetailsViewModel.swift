//
//  PerfumeDetailsViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Observation

@Observable final class PerfumeDetailsViewModel {
    let perfume: SearchPerfumeItem
    var perfumeDetails: PerfumeDetails?
    var isLoading = false
    var hasLoadedOnce = false
    var errorMessage: String?

    init(perfume: SearchPerfumeItem) {
        self.perfume = perfume
    }
}
