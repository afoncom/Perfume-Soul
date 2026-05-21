//
//  SearchPerfumeItem.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

struct SearchPerfumeItem {
    let name: String
}

extension SearchPerfumeItem {
    init(response: SearchPerfumeResponse) {
        self.name = response.name
    }
}
