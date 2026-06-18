//
//  ComparePerfumesViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Combine
import Observation

@Observable final class ComparePerfumesViewModel {
    var leftPerfume: ComparePerfume?
    var rightPerfume: ComparePerfume?
    var isLoading = false
    var hasLoadedOnce = false
    var errorMessage: String?
}
