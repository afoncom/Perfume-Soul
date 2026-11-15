//
//  TodayEnergyPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol TodayEnergyPresenter {
    func refresh() async
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
    func refresh() async {
        do {
            let horoscopes = try await dailyHoroscopeService.requestDailyHoroscope()
            guard let personal = horoscopes.first(where: { $0.sign == viewModel.personalDailyHoroscope.sign }) else {
                viewModel.isUnavailable = true
                return
            }
            viewModel.dailyHoroscopes = horoscopes
            viewModel.personalDailyHoroscope = personal
            viewModel.isUnavailable = false
        } catch {
            viewModel.isUnavailable = true
        }
    }
}
