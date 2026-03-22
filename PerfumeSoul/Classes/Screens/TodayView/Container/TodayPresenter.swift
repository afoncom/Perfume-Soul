//
//  TodayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

protocol TodayPresenter {
    func todayEnergyButtonTab()
    func dayInPerfumeryButtonTab()
}

final class TodayPresenterImpl {
    private let viewModel: TodayViewModel
    private let router: TodayRouter
    
    init(
        viewModel: TodayViewModel,
        router: TodayRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension TodayPresenterImpl: TodayPresenter {
    func todayEnergyButtonTab() {
        router.showTodayEnergyScreen()
    }
    
    func dayInPerfumeryButtonTab() {
        router.showDayInPerfumeryScreen()
    }
}
