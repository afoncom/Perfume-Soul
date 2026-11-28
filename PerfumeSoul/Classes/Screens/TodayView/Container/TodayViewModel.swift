//
//  TodayViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import Foundation
import Observation

@Observable final class TodayViewModel {
    var refreshID = 0
    var notificationTarget: DailyNotificationKind?
    var historyFact: PerfumeHistory?
    var dailyHoroscopes: [DailyHoroscope] = []
    var personalHoroscope: DailyHoroscope?
    var hasPreferredZodiacSign = false
    var isLoadingHoroscope = true
    var viewState: TodayScreen.ViewState = .loading

    var dateText: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    var horoscopePlaceholder: String {
        if hasPreferredZodiacSign {
            return String(localized: "today.energy.unavailable")
        }
        return L10n.Today.Energy.missingProfile
    }
}
