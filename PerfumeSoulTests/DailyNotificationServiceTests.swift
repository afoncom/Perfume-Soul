import UserNotifications
import XCTest
@testable import PerfumeSoul

final class DailyNotificationServiceTests: XCTestCase {
    func testDisablingHoroscopeDoesNotCancelAHistoryReminderBeingScheduled() async throws {
        let suite = "tests.notifications.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let scheduler = NotificationSchedulerStub()
        let started = expectation(description: "History scheduling started")
        scheduler.onSchedulingStarted = { started.fulfill() }
        let service = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: NotificationProfileStub(),
            userDefaults: defaults
        )
        let historyTask = Task { try await service.enableNotification(for: .history) }
        await fulfillment(of: [started], timeout: 2)

        await service.disableNotification(for: .horoscope)
        scheduler.resumeScheduling()
        try await historyTask.value

        XCTAssertTrue(defaults.bool(forKey: "settings.notifications.dailyHistory"))
        XCTAssertEqual(scheduler.removedIdentifiers, ["daily_horoscope_notification"])
        XCTAssertEqual(scheduler.requests.map(\.identifier), ["daily_history_notification"])
    }

    func testHistorySchedulesAtNineteenWithoutAProfileAndDisablesOnlyItself() async throws {
        let suite = "tests.notifications.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "settings.notifications.dailyHoroscope")
        let scheduler = NotificationSchedulerStub()
        let service = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: NotificationProfileStub(),
            userDefaults: defaults
        )

        try await service.enableNotification(for: .history)

        let request = try XCTUnwrap(scheduler.requests.first)
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(request.identifier, "daily_history_notification")
        XCTAssertEqual(trigger.dateComponents.hour, 19)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
        XCTAssertTrue(trigger.repeats)
        XCTAssertFalse(request.content.body.isEmpty)
        let isEnabled = await service.isNotificationEnabled(for: .history)
        XCTAssertTrue(isEnabled)

        await service.disableNotification(for: .history)

        XCTAssertEqual(scheduler.removedIdentifiers, ["daily_history_notification"])
        XCTAssertFalse(defaults.bool(forKey: "settings.notifications.dailyHistory"))
        XCTAssertTrue(defaults.bool(forKey: "settings.notifications.dailyHoroscope"))
    }

    func testDeniedPermissionDoesNotScheduleOrSaveAnEnabledPreference() async throws {
        let suite = "tests.notifications.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let scheduler = NotificationSchedulerStub()
        scheduler.status = .denied
        let service = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: NotificationProfileStub(),
            userDefaults: defaults
        )

        do {
            try await service.enableNotification(for: .history)
            XCTFail("Denied permission must reject enabling the reminder")
        } catch DailyNotificationServiceError.permissionDenied {
            XCTAssertTrue(scheduler.requests.isEmpty)
            XCTAssertFalse(defaults.bool(forKey: "settings.notifications.dailyHistory"))
        }
    }

    func testSchedulingFailureDoesNotEnableTheToggle() async throws {
        let suite = "tests.notifications.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let scheduler = NotificationSchedulerStub()
        scheduler.shouldFailScheduling = true
        let service = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: NotificationProfileStub(),
            userDefaults: defaults
        )

        do {
            try await service.enableNotification(for: .history)
            XCTFail("Scheduling failure must propagate")
        } catch {
            XCTAssertFalse(defaults.bool(forKey: "settings.notifications.dailyHistory"))
        }
    }
}

private final class NotificationSchedulerStub: UserNotificationScheduling {
    var status: UNAuthorizationStatus = .authorized
    var shouldFailScheduling = false
    var requests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var onSchedulingStarted: (() -> Void)?
    private var schedulingContinuation: CheckedContinuation<Void, Never>?

    func authorizationStatus() async -> UNAuthorizationStatus { status }
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { true }
    func add(_ request: UNNotificationRequest) async throws {
        if shouldFailScheduling {
            throw URLError(.unknown)
        }
        if let onSchedulingStarted {
            await withCheckedContinuation { continuation in
                schedulingContinuation = continuation
                onSchedulingStarted()
            }
        }
        requests.append(request)
    }

    func resumeScheduling() {
        schedulingContinuation?.resume()
        schedulingContinuation = nil
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}

private final class NotificationProfileStub: ProfileService {
    func saveProfile(_ profile: Profile) { }
    func replaceProfile(_ profile: Profile) async { }
    func fetchProfile() async -> Profile? { nil }
    func deleteProfile(_ profile: Profile) async { }
}
