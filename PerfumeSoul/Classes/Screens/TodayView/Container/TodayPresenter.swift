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
    @MainActor private var latestLoadID = 0
    
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
        latestLoadID += 1
        let loadID = latestLoadID
        viewModel.viewState = .loading
        viewModel.isLoadingHoroscope = true
        async let historyFactTask = perfumeHistoryService.requestPerfumeHistory()
        async let dailyHoroscopesTask = dailyHoroscopeService.requestDailyHoroscope()
        async let profileTask = profileService.fetchProfile()

        let profile = await profileTask
        let dailyHoroscopes = (try? await dailyHoroscopesTask) ?? []
        guard loadID == latestLoadID else {
            return
        }
        let userSign = profile?.preferredZodiacSign
        viewModel.dailyHoroscopes = dailyHoroscopes
        viewModel.hasPreferredZodiacSign = userSign != nil
        viewModel.personalHoroscope = dailyHoroscopes.first { horoscope in
            horoscope.sign == userSign
        }
        viewModel.isLoadingHoroscope = false

        do {
            let historyFact = try await historyFactTask
            guard loadID == latestLoadID else {
                return
            }
            viewModel.historyFact = historyFact
            viewModel.viewState = .loaded(historyFact: historyFact)
        } catch {
            guard loadID == latestLoadID else {
                return
            }
            viewModel.historyFact = nil
            viewModel.viewState = .unavailable
        }
    }

    func todayEnergyButtonTab() {
        guard let personalHoroscope = viewModel.personalHoroscope else {
            return
        }

        router.showTodayEnergyScreen(
            personalDailyHoroscope: personalHoroscope,
            dailyHoroscopes: viewModel.dailyHoroscopes
        )
    }
    
    func dayInPerfumeryButtonTab() {
        guard case let .loaded(historyFact) = viewModel.viewState else {
            return
        }

        router.showDayInPerfumeryScreen(historyFact: historyFact)
    }
}
