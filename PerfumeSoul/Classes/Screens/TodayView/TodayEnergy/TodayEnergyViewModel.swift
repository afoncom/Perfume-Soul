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
    let personalDailyHoroscope: DailyHoroscope?
    let dailyHoroscopes: [DailyHoroscope]

    init(
        personalDailyHoroscope: DailyHoroscope?,
        dailyHoroscopes: [DailyHoroscope]
    ) {
        self.personalDailyHoroscope = personalDailyHoroscope
        self.dailyHoroscopes = dailyHoroscopes
    }
}
