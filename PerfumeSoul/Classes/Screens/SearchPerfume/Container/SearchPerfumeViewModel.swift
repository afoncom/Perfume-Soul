//
//  SearchPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

@Observable final class SearchPerfumeViewModel {
    var searchText = ""
    var activeSearchText = ""
    var perfumes: [SearchPerfumeItem] = []
    var errorMessage: String?
    var isLoading = false
    var isLoadingMore = false
    var hasLoadedOnce = false
    var canLoadMore = false
}
