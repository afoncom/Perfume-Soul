//
//  DiscoverViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Combine
import Observation

@Observable final class DiscoverViewModel {
    var comparePerfumes: [ComparePerfumeInput] = [
        ComparePerfumeInput(title: "Perfume A"),
        ComparePerfumeInput(title: "Perfume B")
    ]
}
