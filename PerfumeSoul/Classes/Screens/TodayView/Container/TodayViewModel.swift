//
//  TodayViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import Foundation
import Observation

@Observable final class TodayViewModel {
    var historyFact: PerfumeHistory?
    var dailyHoroscopes: [DailyHoroscope] = []
    var personalHoroscope: DailyHoroscope?
    var viewState: TodayScreen.ViewState = .loading

    var dateText: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    func historyDateText(year: Int) -> String {
        "\(Date().formatted(.dateTime.day().month(.wide))) \(year)"
    }
}
