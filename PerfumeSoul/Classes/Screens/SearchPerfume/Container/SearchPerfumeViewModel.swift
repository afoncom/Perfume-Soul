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
    var pageText = "1"
    var itemsPerPageText = "10"
    var perfumes: [SearchPerfumeItem] = []
    var isLoading = false
    var hasSearched = false
}
