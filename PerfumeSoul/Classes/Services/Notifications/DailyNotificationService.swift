import Foundation
import UserNotifications

enum DailyNotificationKind: CaseIterable, Hashable {
    case horoscope
    case history
    case dailyPerfume

    var identifier: String {
        switch self {
        case .horoscope: return "daily_horoscope_notification"
        case .history: return "daily_history_notification"
        case .dailyPerfume: return "daily_perfume_notification"
        }
    }

    var preferenceKey: String {
        switch self {
        case .horoscope: return "settings.notifications.dailyHoroscope"
        case .history: return "settings.notifications.dailyHistory"
        case .dailyPerfume: return "settings.notifications.dailyPerfume"
        }
    }

    var hour: Int {
        switch self {
        case .horoscope: return 9
        case .history: return 19
        case .dailyPerfume: return 8
        }
    }
}

enum DailyNotificationServiceError: Error {
    case permissionDenied
    case profileUnavailable
}

protocol DailyNotificationService {
    func isNotificationEnabled(for kind: DailyNotificationKind) async -> Bool
    func enableNotification(for kind: DailyNotificationKind) async throws
    func disableNotification(for kind: DailyNotificationKind) async
}

protocol UserNotificationScheduling {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationScheduling {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}

final class DailyNotificationServiceImpl {
    private actor OperationCoordinator {
        private var latestOperationIDs: [DailyNotificationKind: Int] = [:]
        private var pendingOperations: [DailyNotificationKind: Task<Void, Error>] = [:]

        func beginOperation(for kind: DailyNotificationKind) -> Int {
            let operationID = (latestOperationIDs[kind] ?? 0) + 1
            latestOperationIDs[kind] = operationID
            return operationID
        }

        func isCurrent(_ operationID: Int, for kind: DailyNotificationKind) -> Bool {
            latestOperationIDs[kind] == operationID
        }

        // Validate and commit synchronously so disable cannot interleave its false write.
        func commitIfCurrent(
            _ operationID: Int,
            for kind: DailyNotificationKind,
            action: () -> Void
        ) {
            guard isCurrent(operationID, for: kind) else {
                return
            }
            action()
        }

        func performDisable(
            for kind: DailyNotificationKind,
            onBegin: () -> Void,
            action: @escaping () -> Void
        ) async {
            _ = beginOperation(for: kind)
            onBegin()
            let previous = pendingOperations[kind]
            // Removal remains mandatory even if a newer enable fails validation.
            // Enqueue before yielding so any valid new add runs after this removal.
            let task = Task<Void, Error> {
                _ = try? await previous?.value
                action()
            }
            pendingOperations[kind] = task
            _ = try? await task.value
        }

        // Serialize system writes per reminder so a late add cannot undo a newer disable.
        func perform(
            _ operationID: Int,
            for kind: DailyNotificationKind,
            action: @escaping () async throws -> Void
        ) async throws {
            let previous = pendingOperations[kind]
            let task = Task {
                _ = try? await previous?.value
                guard isCurrent(operationID, for: kind) else {
                    return
                }
                try await action()
            }
            pendingOperations[kind] = task
            try await task.value
        }
    }

    private let userNotificationCenter: any UserNotificationScheduling
    private let profileService: ProfileService
    private let userDefaults: UserDefaults
    private let operationCoordinator = OperationCoordinator()

    init(
        userNotificationCenter: any UserNotificationScheduling = UNUserNotificationCenter.current(),
        profileService: ProfileService,
        userDefaults: UserDefaults = .standard
    ) {
        self.userNotificationCenter = userNotificationCenter
        self.profileService = profileService
        self.userDefaults = userDefaults
    }
}

extension DailyNotificationServiceImpl: DailyNotificationService {
    func isNotificationEnabled(for kind: DailyNotificationKind) async -> Bool {
        guard userDefaults.bool(forKey: kind.preferenceKey) else {
            return false
        }
        let status = await userNotificationCenter.authorizationStatus()
        return status == .authorized || status == .provisional || status == .ephemeral
    }

    func enableNotification(for kind: DailyNotificationKind) async throws {
        let operationID = await operationCoordinator.beginOperation(for: kind)
        let isAuthorized = try await requestNotificationAuthorizationIfNeeded()
        guard await operationCoordinator.isCurrent(operationID, for: kind) else {
            return
        }
        guard isAuthorized else {
            throw DailyNotificationServiceError.permissionDenied
        }

        let content = try await makeNotificationContent(for: kind)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: kind.hour, minute: 0),
            repeats: true
        )
        let request = UNNotificationRequest(identifier: kind.identifier, content: content, trigger: trigger)
        try await operationCoordinator.perform(operationID, for: kind) { [self] in
            try await userNotificationCenter.add(request)
            await operationCoordinator.commitIfCurrent(operationID, for: kind) {
                self.userDefaults.set(true, forKey: kind.preferenceKey)
            }
        }
    }

    func disableNotification(for kind: DailyNotificationKind) async {
        await operationCoordinator.performDisable(
            for: kind,
            onBegin: { [self] in userDefaults.set(false, forKey: kind.preferenceKey) },
            action: { [self] in
                userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [kind.identifier])
            }
        )
    }
}

extension DailyNotificationServiceImpl {
    private func requestNotificationAuthorizationIfNeeded() async throws -> Bool {
        switch await userNotificationCenter.authorizationStatus() {
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

    private func makeNotificationContent(for kind: DailyNotificationKind) async throws -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        switch kind {
        case .horoscope:
            guard let profile = await profileService.fetchProfile(), profile.preferredZodiacSign != nil else {
                throw DailyNotificationServiceError.profileUnavailable
            }
            content.title = L10n.Settings.Notification.dailyHoroscopeTitle
            content.body = L10n.Settings.Notification.dailyHoroscopeReminderBody
        case .history:
            content.title = L10n.Settings.Notification.dayInPerfumeryTitle
            content.body = String(localized: "settings.notification.historyReminderBody")
        case .dailyPerfume:
            guard let profile = await profileService.fetchProfile(), profile.cachedProfileCalculation != nil else {
                throw DailyNotificationServiceError.profileUnavailable
            }
            content.title = L10n.Settings.Notification.aromaOfTheDayTitle
            content.body = String(localized: "settings.notification.dailyPerfumeReminderBody")
        }
        content.sound = .default
        content.threadIdentifier = kind.identifier
        return content
    }
}
