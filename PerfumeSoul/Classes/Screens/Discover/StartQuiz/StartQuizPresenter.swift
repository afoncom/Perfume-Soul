//
//  StartQuizPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol StartQuizPresenter {
    
}

final class StartQuizPresenterImpl {
    private let viewModel: StartQuizViewModel
    private let router: StartQuizRouter
    
    init(
        viewModel: StartQuizViewModel,
        router: StartQuizRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension StartQuizPresenterImpl: StartQuizPresenter {
    
}
