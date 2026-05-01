//
//  TodayEnergyPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol TodayEnergyPresenter {
    func onAppear() async
}

final class TodayEnergyPresenterImpl {
    private let viewModel: TodayEnergyViewModel
    private let router: TodayEnergyRouter
    private let dailyHoroscopeService: DailyHoroscopeService
    
    init(
        viewModel: TodayEnergyViewModel,
        router: TodayEnergyRouter,
        dailyHoroscopeService: DailyHoroscopeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.dailyHoroscopeService = dailyHoroscopeService
    }
}

extension TodayEnergyPresenterImpl: TodayEnergyPresenter {
    @MainActor
    func onAppear() async {
        do {
            let result = try await dailyHoroscopeService.requestDailyHoroscope()
            print(result)
        } catch let error {
            print(error)
        }
    }
}
