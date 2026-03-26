//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CalculationPresenter {
    func continueButtonTapped()
}

final class CalculationPresenterImpl {
    private let viewModel: CalculationViewModel
    private let router: CalculationRouter
    
    init(
        viewModel: CalculationViewModel,
        router: CalculationRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension CalculationPresenterImpl: CalculationPresenter {
    func continueButtonTapped() {
        router.finishCalculation()
    }
}
