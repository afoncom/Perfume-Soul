//
//  TodayEnergyViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Combine
import Observation

@Observable final class TodayEnergyViewModel {
    let personalDailyHoroscope: DailyHoroscopeResponse?
    let dailyHoroscopes: [DailyHoroscopeResponse]

    init(
        personalDailyHoroscope: DailyHoroscopeResponse?,
        dailyHoroscopes: [DailyHoroscopeResponse]
    ) {
        self.personalDailyHoroscope = personalDailyHoroscope
        self.dailyHoroscopes = dailyHoroscopes
    }

    var resolvedPersonalDailyHoroscope: DailyHoroscopeResponse? {
        personalDailyHoroscope ?? dailyHoroscopes.first
    }
}
