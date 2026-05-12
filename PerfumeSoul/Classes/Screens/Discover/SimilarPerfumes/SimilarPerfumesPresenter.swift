//
//  SimilarPerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SimilarPerfumesPresenter {
    
}

final class SimilarPerfumesPresenterImpl {
    private let viewModel: SimilarPerfumesViewModel
    private let router: SimilarPerfumesRouter
    
    init(
        viewModel: SimilarPerfumesViewModel,
        router: SimilarPerfumesRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension SimilarPerfumesPresenterImpl: SimilarPerfumesPresenter {
    
}
