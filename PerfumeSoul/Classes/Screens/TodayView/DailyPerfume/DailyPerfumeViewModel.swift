//
//  DailyPerfumeViewState.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

enum DailyPerfumeViewState: Equatable {
    case loading
    case missingProfile
    case content(DailyPerfumeSummary, DailyPerfumeReaction)
    case exhausted
    case failed
}

@Observable final class DailyPerfumeViewModel {
    var state: DailyPerfumeViewState = .loading
}
