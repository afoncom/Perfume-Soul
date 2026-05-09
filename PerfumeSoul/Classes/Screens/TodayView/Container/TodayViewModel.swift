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
    var dailyHoroscopes: [DailyHoroscope] = []
    var personalHoroscope: DailyHoroscope?
    var viewState: TodayScreen.ViewState = .loading
}
