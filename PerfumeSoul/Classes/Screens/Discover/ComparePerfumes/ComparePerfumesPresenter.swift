//
//  ComparePerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ComparePerfumesPresenter {
    
}

final class ComparePerfumesPresenterImpl {
    private let viewModel: ComparePerfumesViewModel
    private let router: ComparePerfumesRouter
    
    init(
        viewModel: ComparePerfumesViewModel,
        router: ComparePerfumesRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension ComparePerfumesPresenterImpl: ComparePerfumesPresenter {
    
}
