//
//  TodayViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import Foundation
import Observation

@Observable final class TodayViewModel {
    var historyFact: PerfumeInHistoryResponse?
    var dailyHoroscopes: [DailyHoroscopeResponse] = []
    var personalDailyHoroscope: DailyHoroscopeResponse?

    var resolvedPersonalDailyHoroscope: DailyHoroscopeResponse? {
        personalDailyHoroscope ?? dailyHoroscopes.first
    }
    var viewState: TodayScreen.ViewState = .loading
}
