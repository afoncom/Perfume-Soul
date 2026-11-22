//
//  SettingsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

@MainActor
protocol SettingsPresenter {
    func onAppear() async
    func dailyHoroscopeNotificationToggled(isEnabled: Bool)
    func dailyHistoryNotificationToggled(isEnabled: Bool)
    func feedbackButtonTapped()
    func openSystemSettingsTapped()
    func notificationAlertDismissed()
}

final class SettingsPresenterImpl {
    private let viewModel: SettingsViewModel
    private let router: SettingsRouter
    private let notificationService: DailyNotificationService
    private var notificationToggleTasks: [DailyNotificationKind: Task<Void, Never>] = [:]
    private var notificationToggleRevisions: [DailyNotificationKind: Int] = [:]
    
    init(
        viewModel: SettingsViewModel,
        router: SettingsRouter,
        notificationService: DailyNotificationService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.notificationService = notificationService
    }
}

extension SettingsPresenterImpl: SettingsPresenter {
    @MainActor
    func onAppear() async {
        for kind in DailyNotificationKind.allCases {
            let revision = notificationToggleRevisions[kind, default: 0]
            let isEnabled = await notificationService.isNotificationEnabled(for: kind)
            if notificationToggleRevisions[kind, default: 0] == revision,
                notificationToggleTasks[kind] == nil {
                setNotificationEnabled(isEnabled, for: kind)
            }
        }
    }

    func dailyHoroscopeNotificationToggled(isEnabled: Bool) {
        toggleNotification(.horoscope, isEnabled: isEnabled)
    }

    func dailyHistoryNotificationToggled(isEnabled: Bool) {
        toggleNotification(.history, isEnabled: isEnabled)
    }

    func feedbackButtonTapped() {
        router.showSendFeedback()
    }

    func openSystemSettingsTapped() {
        router.openSystemSettings()
    }

    @MainActor
    func notificationAlertDismissed() {
        viewModel.notificationAlertTitle = nil
        viewModel.notificationAlertMessage = nil
        viewModel.showsNotificationSettingsAction = false
    }
}

extension SettingsPresenterImpl {
    @MainActor
    private func setNotificationEnabled(_ isEnabled: Bool, for kind: DailyNotificationKind) {
        switch kind {
        case .horoscope:
            viewModel.isDailyHoroscopeNotificationEnabled = isEnabled
        case .history:
            viewModel.isDailyHistoryNotificationEnabled = isEnabled
        }
    }

    @MainActor
    private func toggleNotification(_ kind: DailyNotificationKind, isEnabled: Bool) {
        notificationToggleRevisions[kind, default: 0] += 1
        setNotificationEnabled(isEnabled, for: kind)
        notificationToggleTasks[kind]?.cancel()
        notificationToggleTasks[kind] = Task { @MainActor [weak self] in
            guard let self, !Task.isCancelled else {
                return
            }
            defer {
                if !Task.isCancelled {
                    notificationToggleTasks[kind] = nil
                }
            }

            if isEnabled {
                do {
                    try await notificationService.enableNotification(for: kind)
                    guard !Task.isCancelled else {
                        return
                    }

                    setNotificationEnabled(true, for: kind)
                } catch let error as DailyNotificationServiceError {
                    guard !Task.isCancelled else {
                        return
                    }

                    setNotificationEnabled(false, for: kind)
                    presentNotificationError(error, for: kind)
                } catch {
                    guard !Task.isCancelled else {
                        return
                    }

                    setNotificationEnabled(false, for: kind)
                    presentUnknownNotificationError(for: kind)
                }
            } else {
                await notificationService.disableNotification(for: kind)
                guard !Task.isCancelled else {
                    return
                }

                setNotificationEnabled(false, for: kind)
            }
        }
    }

    @MainActor
    private func presentNotificationError(_ error: DailyNotificationServiceError, for kind: DailyNotificationKind) {
        switch error {
        case .permissionDenied:
            viewModel.notificationAlertTitle = L10n.Settings.Notification.permissionDeniedTitle
            viewModel.notificationAlertMessage = kind == .history
                ? String(localized: "settings.notification.historyPermissionDeniedMessage")
                : L10n.Settings.Notification.permissionDeniedMessage
            viewModel.showsNotificationSettingsAction = true
        case .profileUnavailable:
            viewModel.notificationAlertTitle = L10n.Settings.Notification.profileRequiredTitle
            viewModel.notificationAlertMessage = L10n.Settings.Notification.profileRequiredMessage
            viewModel.showsNotificationSettingsAction = false
        }

        viewModel.isShowingNotificationAlert = true
    }

    @MainActor
    private func presentUnknownNotificationError(for kind: DailyNotificationKind) {
        viewModel.notificationAlertTitle = kind == .history
            ? String(localized: "settings.notification.historyUnavailableTitle")
            : L10n.Settings.Notification.unavailableTitle
        viewModel.notificationAlertMessage = L10n.Common.Error.message
        viewModel.showsNotificationSettingsAction = false
        viewModel.isShowingNotificationAlert = true
    }
}
