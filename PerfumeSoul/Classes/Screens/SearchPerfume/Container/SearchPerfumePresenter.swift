//
//  SearchPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SearchPerfumePresenter {
    
}

final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    
    init(
        viewModel: SearchPerfumeViewModel,
        router: SearchPerfumeRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension SearchPerfumePresenterImpl: SearchPerfumePresenter {
    
}
