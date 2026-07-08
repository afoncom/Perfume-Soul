//
//  SettingsViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

@Observable final class SettingsViewModel {
    var isDailyHoroscopeNotificationEnabled = false
    var notificationAlertTitle: String?
    var notificationAlertMessage: String?
    var isShowingNotificationAlert = false
    var showsNotificationSettingsAction = false
}
