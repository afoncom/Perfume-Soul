//
//  SearchPerfumeItem.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct SearchPerfumeItem: Equatable, Identifiable {
    let id: Int
    let name: String
}

extension SearchPerfumeItem {
    init(response: SearchPerfumeResponse) {
        self.id = response.id
        self.name = response.name
    }
}
