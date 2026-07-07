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
    case horoscopeUnavailable
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
    }

    private let userNotificationCenter: UNUserNotificationCenter
    private let dailyHoroscopeService: DailyHoroscopeService
    private let profileService: ProfileService
    private let userDefaults: UserDefaults

    init(
        userNotificationCenter: UNUserNotificationCenter = .current(),
        dailyHoroscopeService: DailyHoroscopeService,
        profileService: ProfileService,
        userDefaults: UserDefaults = .standard
    ) {
        self.userNotificationCenter = userNotificationCenter
        self.dailyHoroscopeService = dailyHoroscopeService
        self.profileService = profileService
        self.userDefaults = userDefaults
    }
}

extension DailyHoroscopeNotificationServiceImpl: DailyHoroscopeNotificationService {
    func isDailyHoroscopeNotificationEnabled() -> Bool {
        userDefaults.bool(forKey: Constants.isEnabledKey)
    }

    func enableDailyHoroscopeNotification() async throws {
        let isAuthorized = try await requestNotificationAuthorizationIfNeeded()

        guard isAuthorized else {
            throw DailyHoroscopeNotificationServiceError.permissionDenied
        }

        let content = try await makeNotificationContent()
        try await scheduleNotification(content: content)
        userDefaults.set(true, forKey: Constants.isEnabledKey)
    }

    func disableDailyHoroscopeNotification() async {
        userDefaults.set(false, forKey: Constants.isEnabledKey)
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Constants.notificationIdentifier])
    }

    func refreshDailyHoroscopeNotificationIfNeeded() async {
        guard isDailyHoroscopeNotificationEnabled() else {
            return
        }

        let settings = await userNotificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional ||
                settings.authorizationStatus == .ephemeral else {
            await disableDailyHoroscopeNotification()
            return
        }

        do {
            let content = try await makeNotificationContent()
            try await scheduleNotification(content: content)
        } catch {
            // Keep the existing scheduled notification if refresh fails.
        }
    }
}

private extension DailyHoroscopeNotificationServiceImpl {
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
        guard let profile = await profileService.fetchProfile(),
              let sign = profile.zodiacSign() else {
            throw DailyHoroscopeNotificationServiceError.profileUnavailable
        }

        let dailyHoroscopes = try await dailyHoroscopeService.requestDailyHoroscope()

        guard let horoscope = dailyHoroscopes.first(where: { $0.sign == sign }) else {
            throw DailyHoroscopeNotificationServiceError.horoscopeUnavailable
        }

        let content = UNMutableNotificationContent()
        content.title = L10n.Settings.Notification.dailyHoroscopeTitle
        content.subtitle = horoscope.displayName
        content.body = horoscope.energyOfDay
        content.sound = .default
        content.threadIdentifier = Constants.notificationIdentifier
        return content
    }

    func scheduleNotification(content: UNMutableNotificationContent) async throws {
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 9, minute: 0),
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
