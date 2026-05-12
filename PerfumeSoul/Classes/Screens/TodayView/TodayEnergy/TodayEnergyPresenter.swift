//
//  TodayEnergyPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol TodayEnergyPresenter {
    
}

final class TodayEnergyPresenterImpl {
    private let viewModel: TodayEnergyViewModel
    private let router: TodayEnergyRouter
    
    init(
        viewModel: TodayEnergyViewModel,
        router: TodayEnergyRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension TodayEnergyPresenterImpl: TodayEnergyPresenter {
    
}
