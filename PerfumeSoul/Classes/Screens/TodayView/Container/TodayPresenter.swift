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
        do {
            async let historyFactTask = perfumeHistoryService.requestPerfumeHistory()
            async let dailyHoroscopesTask = dailyHoroscopeService.requestDailyHoroscope()
            async let profileTask = profileService.fetchProfile()
            
            let historyFact = try await historyFactTask
            let dailyHoroscopes = try await dailyHoroscopesTask
            let profile = await profileTask
            
            viewModel.historyFact = historyFact
            viewModel.dailyHoroscopes = dailyHoroscopes
            viewModel.personalDailyHoroscope = makePersonalDailyHoroscope(
                profile: profile,
                dailyHoroscopes: dailyHoroscopes
            )
        } catch let error {
            print(error)
        }
    }

    func todayEnergyButtonTab() {
        router.showTodayEnergyScreen(
            personalDailyHoroscope: viewModel.personalDailyHoroscope,
            dailyHoroscopes: viewModel.dailyHoroscopes
        )
    }
    
    func dayInPerfumeryButtonTab() {
        router.showDayInPerfumeryScreen(historyFact: viewModel.historyFact)
    }
}

private extension TodayPresenterImpl {
    func makePersonalDailyHoroscope(
        profile: Profile?,
        dailyHoroscopes: [DailyHoroscopeResponse]
    ) -> DailyHoroscopeResponse? {
        guard
            let profile,
            let zodiacSign = zodiacSign(from: profile.birthDate)
        else {
            return nil
        }
        
        return dailyHoroscopes.first { $0.sign == zodiacSign }
    }
    
    func zodiacSign(from birthDate: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let date = formatter.date(from: birthDate) else {
            return nil
        }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "aries"
        case (4, 20...30), (5, 1...20): return "taurus"
        case (5, 21...31), (6, 1...20): return "gemini"
        case (6, 21...30), (7, 1...22): return "cancer"
        case (7, 23...31), (8, 1...22): return "leo"
        case (8, 23...31), (9, 1...22): return "virgo"
        case (9, 23...30), (10, 1...22): return "libra"
        case (10, 23...31), (11, 1...21): return "scorpio"
        case (11, 22...30), (12, 1...21): return "sagittarius"
        case (12, 22...31), (1, 1...19): return "capricorn"
        case (1, 20...31), (2, 1...18): return "aquarius"
        case (2, 19...29), (3, 1...20): return "pisces"
        default: return nil
        }
    }
}
