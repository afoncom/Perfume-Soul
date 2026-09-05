//
//  CabinetViewState.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

enum CabinetViewState: Equatable {
    case loading
    case empty
    case content([DailyPerfumeSummary])
}

@Observable final class CabinetViewModel {
    var state: CabinetViewState = .loading
}
