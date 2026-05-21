//
//  QuizOfTheDayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol QuizOfTheDayPresenter {
    
}

final class QuizOfTheDayPresenterImpl {
    private let viewModel: QuizOfTheDayViewModel
    private let router: QuizOfTheDayRouter
    
    init(
        viewModel: QuizOfTheDayViewModel,
        router: QuizOfTheDayRouter,
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension QuizOfTheDayPresenterImpl: QuizOfTheDayPresenter {
    
}
