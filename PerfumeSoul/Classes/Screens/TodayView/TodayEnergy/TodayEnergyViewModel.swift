//
//  TodayEnergyViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

@Observable final class TodayEnergyViewModel {
    var personalDailyHoroscope: DailyHoroscope
    var dailyHoroscopes: [DailyHoroscope]
    var isUnavailable = false

    init(
        personalDailyHoroscope: DailyHoroscope,
        dailyHoroscopes: [DailyHoroscope]
    ) {
        self.personalDailyHoroscope = personalDailyHoroscope
        self.dailyHoroscopes = dailyHoroscopes
    }
}
