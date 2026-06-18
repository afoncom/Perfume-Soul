//
//  ComparePerfumeSelectionService.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct ComparePerfumeSelection {
    let leftPerfumeID: Int
    let rightPerfumeID: Int
}

protocol ComparePerfumeSelectionService {
    func saveSelection(_ selection: ComparePerfumeSelection)
    func fetchSelection() -> ComparePerfumeSelection?
}

final class ComparePerfumeSelectionServiceImpl {
    private var selection: ComparePerfumeSelection?
}

extension ComparePerfumeSelectionServiceImpl: ComparePerfumeSelectionService {
    func saveSelection(_ selection: ComparePerfumeSelection) {
        self.selection = selection
    }

    func fetchSelection() -> ComparePerfumeSelection? {
        selection
    }
}
