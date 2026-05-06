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
    var personalDailyHoroscope: DailyHoroscopeResponse?
    var dailyHoroscopes: [DailyHoroscopeResponse] = []

    var resolvedPersonalDailyHoroscope: DailyHoroscopeResponse? {
        personalDailyHoroscope ?? dailyHoroscopes.first
    }
}
