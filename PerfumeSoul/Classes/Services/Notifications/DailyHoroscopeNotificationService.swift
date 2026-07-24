//
//  DailyHoroscopeNotificationService.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.07.2026.
//

import Foundation
import OSLog
import UserNotifications

enum DailyHoroscopeNotificationServiceError: Error {
    case permissionDenied
    case profileUnavailable
}

protocol DailyHoroscopeNotificationService {
    func isDailyHoroscopeNotificationEnabled() -> Bool
    func enableDailyHoroscopeNotification() async throws
    func disableDailyHoroscopeNotification() async
    func refreshDailyHoroscopeNotificationIfNeeded() async
}

final class DailyHoroscopeNotificationServiceImpl {
    private enum Constants {
        static let notificationIdentifier = "daily_horoscope_notification"
        static let isEnabledKey = "settings.notifications.dailyHoroscope"
        static let notificationHour = 9
        static let notificationMinute = 0
    }

    private actor OperationCoordinator {
        private var latestOperationID = 0

        func beginOperation() -> Int {
            latestOperationID += 1
            return latestOperationID
        }

        func isCurrent(_ operationID: Int) -> Bool {
            latestOperationID == operationID
        }
    }

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PerfumeSoul",
        category: "DailyHoroscopeNotificationService"
    )
    private let userNotificationCenter: UNUserNotificationCenter
    private let profileService: ProfileService
    private let userDefaults: UserDefaults
    private let operationCoordinator = OperationCoordinator()

    init(
        userNotificationCenter: UNUserNotificationCenter = .current(),
        profileService: ProfileService,
        userDefaults: UserDefaults = .standard
    ) {
        self.userNotificationCenter = userNotificationCenter
        self.profileService = profileService
        self.userDefaults = userDefaults
    }
}

extension DailyHoroscopeNotificationServiceImpl: DailyHoroscopeNotificationService {
    func isDailyHoroscopeNotificationEnabled() -> Bool {
        userDefaults.bool(forKey: Constants.isEnabledKey)
    }

    func enableDailyHoroscopeNotification() async throws {
        let operationID = await operationCoordinator.beginOperation()
        let isAuthorized = try await requestNotificationAuthorizationIfNeeded()

        guard await operationCoordinator.isCurrent(operationID) else {
            return
        }

        guard isAuthorized else {
            throw DailyHoroscopeNotificationServiceError.permissionDenied
        }

        let content = try await makeNotificationContent()

        guard await operationCoordinator.isCurrent(operationID) else {
            return
        }

        try await scheduleNotification(content: content, for: nextNotificationDate())

        guard await operationCoordinator.isCurrent(operationID) else {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.notificationIdentifier])
            return
        }

        userDefaults.set(true, forKey: Constants.isEnabledKey)
    }

    func disableDailyHoroscopeNotification() async {
        _ = await operationCoordinator.beginOperation()
        userDefaults.set(false, forKey: Constants.isEnabledKey)
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.notificationIdentifier])
    }

    func refreshDailyHoroscopeNotificationIfNeeded() async {
        guard isDailyHoroscopeNotificationEnabled() else {
            return
        }

        let operationID = await operationCoordinator.beginOperation()

        do {
            let content = try await makeNotificationContent()

            guard await operationCoordinator.isCurrent(operationID) else {
                return
            }

            try await scheduleNotification(content: content, for: nextNotificationDate())
        } catch {
            logger.error("Failed to refresh daily horoscope notification: \(error.localizedDescription)")
        }
    }
}

extension DailyHoroscopeNotificationServiceImpl {
    func requestNotificationAuthorizationIfNeeded() async throws -> Bool {
        let settings = await userNotificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return try await userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func makeNotificationContent() async throws -> UNMutableNotificationContent {
        guard
            let profile = await profileService.fetchProfile(),
            let sign = profile.zodiacSign()
        else {
            throw DailyHoroscopeNotificationServiceError.profileUnavailable
        }

        let horoscope = DailyHoroscope(sign: sign, energyOfDay: "")

        let content = UNMutableNotificationContent()
        content.title = L10n.Settings.Notification.dailyHoroscopeTitle
        content.subtitle = horoscope.displayName
        content.body = L10n.Settings.Notification.dailyHoroscopeReminderBody
        content.sound = .default
        content.threadIdentifier = Constants.notificationIdentifier
        return content
    }

    func scheduleNotification(content: UNMutableNotificationContent, for date: Date) async throws {
        let calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: Constants.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.notificationIdentifier])

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            userNotificationCenter.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func nextNotificationDate(from now: Date = Date()) -> Date {
        let calendar = Calendar.current
        let todayNotificationDate = calendar.date(
            bySettingHour: Constants.notificationHour,
            minute: Constants.notificationMinute,
            second: 0,
            of: now
        ) ?? now

        if now < todayNotificationDate {
            return todayNotificationDate
        }

        return calendar.date(byAdding: .day, value: 1, to: todayNotificationDate) ?? todayNotificationDate
    }
}
