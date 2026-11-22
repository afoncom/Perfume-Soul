import XCTest
@testable import PerfumeSoul

final class SettingsPresenterTests: XCTestCase {
    @MainActor
    func testDelayedReadDoesNotRestoreToggleAfterDisableCompletes() async {
        for kind in DailyNotificationKind.allCases {
            let viewModel = SettingsViewModel()
            viewModel.isDailyHistoryNotificationEnabled = true
            viewModel.isDailyHoroscopeNotificationEnabled = true
            let service = DelayedSettingsNotificationService(kind: kind)
            let presenter = SettingsPresenterImpl(
                viewModel: viewModel,
                router: SettingsRouterStub(),
                notificationService: service
            )
            let readStarted = expectation(description: "Read suspended for \(kind)")
            let disableCompleted = expectation(description: "Disable completed for \(kind)")
            service.onReadSuspended = { readStarted.fulfill() }
            service.onDisabled = { disableCompleted.fulfill() }
            let load = Task { await presenter.onAppear() }
            await fulfillment(of: [readStarted], timeout: 2)

            switch kind {
            case .horoscope:
                presenter.dailyHoroscopeNotificationToggled(isEnabled: false)
            case .history:
                presenter.dailyHistoryNotificationToggled(isEnabled: false)
            }
            await fulfillment(of: [disableCompleted], timeout: 2)
            service.resumeRead(with: true)
            await load.value

            XCTAssertFalse(service.isEnabled)
            switch kind {
            case .horoscope:
                XCTAssertFalse(viewModel.isDailyHoroscopeNotificationEnabled)
            case .history:
                XCTAssertFalse(viewModel.isDailyHistoryNotificationEnabled)
            }
        }
    }
}

@MainActor
private final class DelayedSettingsNotificationService: DailyNotificationService {
    var onReadSuspended: (() -> Void)?
    var onDisabled: (() -> Void)?
    private(set) var isEnabled = true
    private let kind: DailyNotificationKind
    private var continuation: CheckedContinuation<Bool, Never>?

    init(kind: DailyNotificationKind) {
        self.kind = kind
    }

    func isNotificationEnabled(for kind: DailyNotificationKind) async -> Bool {
        guard kind == self.kind else {
            return false
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            onReadSuspended?()
        }
    }

    func enableNotification(for kind: DailyNotificationKind) async throws { }

    func disableNotification(for kind: DailyNotificationKind) async {
        isEnabled = false
        onDisabled?()
    }

    func resumeRead(with value: Bool) {
        continuation?.resume(returning: value)
        continuation = nil
    }
}

private final class SettingsRouterStub: SettingsRouter {
    func showSendFeedback() { }
    func openSystemSettings() { }
}
