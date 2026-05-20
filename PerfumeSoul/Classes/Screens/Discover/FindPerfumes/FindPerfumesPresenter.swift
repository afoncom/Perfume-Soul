//
//  FindPerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol FindPerfumesPresenter {
    func findSimilarPerfumesButtonTapped()
}

final class FindPerfumesPresenterImpl {
    private let viewModel: FindPerfumesViewModel
    private let router: FindPerfumesRouter
    
    init(
        viewModel: FindPerfumesViewModel,
        router: FindPerfumesRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension FindPerfumesPresenterImpl: FindPerfumesPresenter {
    func findSimilarPerfumesButtonTapped() {
        router.showPerfumeRecommendationsScreen()
    }
}
