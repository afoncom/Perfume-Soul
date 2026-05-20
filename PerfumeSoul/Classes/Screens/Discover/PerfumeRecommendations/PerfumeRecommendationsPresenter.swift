//
//  PerfumeRecommendationsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeRecommendationsPresenter {
    
}

final class PerfumeRecommendationsPresenterImpl {
    private let viewModel: PerfumeRecommendationsViewModel
    private let router: PerfumeRecommendationsRouter
    
    init(
        viewModel: PerfumeRecommendationsViewModel,
        router: PerfumeRecommendationsRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension PerfumeRecommendationsPresenterImpl: PerfumeRecommendationsPresenter {
    
}
