//
//  RecommendedPerfumeState.swift
//  PerfumeSoul
//
//  Created by afon.com on 11.10.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct RecommendedPerfumeState: StorableViewState, Equatable {
    var perfumes: [DailyPerfumeSummary]
    var reservePerfumes: [DailyPerfumeSummary]
    var topPerfumeIDs: [Int]
    var profileCalculationCacheKey: String?
    var weekKey: String
    var resolvedExcludedPerfumeIDs: [Int]?
}
