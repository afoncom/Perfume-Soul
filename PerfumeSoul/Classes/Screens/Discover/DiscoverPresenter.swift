//
//  DiscoverPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DiscoverPresenter {
    func comparePerfumesButtonTab()
    func startQuizButtonTab()
}

final class DiscoverPresenterImpl {
    private let viewModel: DiscoverViewModel
    private let router: DiscoverRouter
    
    init(
        viewModel: DiscoverViewModel,
        router: DiscoverRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension DiscoverPresenterImpl: DiscoverPresenter {
    func startQuizButtonTab() {
        router.showStartQuizScreen()
    }
    
    func comparePerfumesButtonTab() {
        router.showComparePerfumesScreen()
    }
}
