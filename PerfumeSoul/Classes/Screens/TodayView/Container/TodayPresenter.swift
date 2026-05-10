//
//  TodayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import Foundation

protocol TodayPresenter {
    func onAppear() async
    func todayEnergyButtonTab()
    func dayInPerfumeryButtonTab()
}

final class TodayPresenterImpl {
    private let viewModel: TodayViewModel
    private let router: TodayRouter
    private let perfumeHistoryService: PerfumeHistoryService
    private let dailyHoroscopeService: DailyHoroscopeService
    private let profileService: ProfileService
    
    init(
        viewModel: TodayViewModel,
        router: TodayRouter,
        perfumeHistoryService: PerfumeHistoryService,
        dailyHoroscopeService: DailyHoroscopeService,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeHistoryService = perfumeHistoryService
        self.dailyHoroscopeService = dailyHoroscopeService
        self.profileService = profileService
    }
}

extension TodayPresenterImpl: TodayPresenter {
    @MainActor
    func onAppear() async {
        viewModel.viewState = .loading
        do {
            async let historyFactTask = perfumeHistoryService.requestPerfumeHistory()
            async let dailyHoroscopesTask = dailyHoroscopeService.requestDailyHoroscope()
            async let profileTask = profileService.fetchProfile()
            
            let historyFact = try await historyFactTask
            let dailyHoroscopes = try await dailyHoroscopesTask
            let profile = await profileTask
            let userSign = profile?.zodiacSign()
            
            viewModel.historyFact = historyFact
            viewModel.dailyHoroscopes = dailyHoroscopes
            viewModel.personalHoroscope = dailyHoroscopes.first(where: { horoscope in
                horoscope.sign == userSign
            })
            
            let result = try await perfumeHistoryService.requestPerfumeHistory()
            viewModel.viewState = .loaded(historyFact: result)
            print(result)
        } catch let error {
            print(error)
        }
    }

    func todayEnergyButtonTab() {
        guard let personalHoroscope = viewModel.personalHoroscope else { return }

        router.showTodayEnergyScreen(
            personalDailyHoroscope: personalHoroscope,
            dailyHoroscopes: viewModel.dailyHoroscopes
        )
    }
    
    func dayInPerfumeryButtonTab() {
        guard case let .loaded(historyFact) = viewModel.viewState else { return }
        router.showDayInPerfumeryScreen(historyFact: historyFact)
    }
}
