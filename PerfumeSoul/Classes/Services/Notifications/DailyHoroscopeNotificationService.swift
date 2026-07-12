//
//  DailyHoroscopeNotificationService.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.07.2026.
//

import Foundation
import UserNotifications

enum DailyHoroscopeNotificationServiceError: Error {
    case permissionDenied
    case profileUnavailable
}

protocol DailyHoroscopeNotificationService {
    func isDailyHoroscopeNotificationEnabled() -> Bool
    func enableDailyHoroscopeNotification() async throws
    func disableDailyHoroscopeNotification() async
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

        try await scheduleNotification(content: content)

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
}

extension DailyHoroscopeNotificationServiceImpl {
    private func requestNotificationAuthorizationIfNeeded() async throws -> Bool {
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

    private func makeNotificationContent() async throws -> UNMutableNotificationContent {
        guard await profileService.fetchProfile() != nil else {
            throw DailyHoroscopeNotificationServiceError.profileUnavailable
        }

        let content = UNMutableNotificationContent()
        content.title = L10n.Settings.Notification.dailyHoroscopeTitle
        content.body = L10n.Settings.Notification.dailyHoroscopeReminderBody
        content.sound = .default
        content.threadIdentifier = Constants.notificationIdentifier
        return content
    }

    private func scheduleNotification(content: UNMutableNotificationContent) async throws {
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(
                hour: Constants.notificationHour,
                minute: Constants.notificationMinute
            ),
            repeats: true
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
}
