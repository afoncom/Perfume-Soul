//
//  DiscoverPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DiscoverPresenter {
    
}

final class DiscoverPresenterImpl {
    private let viewModel: ProfileViewMoodel
    private let router: ProfileRouter
    
    init(
        viewModel: ProfileViewMoodel,
        router: ProfileRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension DiscoverPresenterImpl: DiscoverPresenter {
    
}
