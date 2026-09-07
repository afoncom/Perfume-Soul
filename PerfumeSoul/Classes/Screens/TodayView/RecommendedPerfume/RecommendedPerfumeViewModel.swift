//
//  RecommendedPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//


import Observation

enum RecommendedPerfumeViewState: Equatable {
    case loading
    case content([DailyPerfumeSummary])
    case empty
}

@Observable final class RecommendedPerfumeViewModel {
    var state: RecommendedPerfumeViewState = .loading
}
