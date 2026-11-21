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
    func dailyPerfumeNotificationToggled(isEnabled: Bool)
    func feedbackButtonTapped()
    func openSystemSettingsTapped()
    func notificationAlertDismissed()
}

final class SettingsPresenterImpl {
    private let viewModel: SettingsViewModel
    private let router: SettingsRouter
    private let notificationService: DailyNotificationService
    private var notificationToggleTasks: [DailyNotificationKind: Task<Void, Never>] = [:]
    
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
            let isEnabled = await notificationService.isNotificationEnabled(for: kind)
            if notificationToggleTasks[kind] == nil {
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

    func dailyPerfumeNotificationToggled(isEnabled: Bool) {
        toggleNotification(.dailyPerfume, isEnabled: isEnabled)
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
        case .dailyPerfume:
            viewModel.isDailyPerfumeNotificationEnabled = isEnabled
        }
    }

    @MainActor
    private func toggleNotification(_ kind: DailyNotificationKind, isEnabled: Bool) {
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
            switch kind {
            case .horoscope:
                viewModel.notificationAlertMessage = L10n.Settings.Notification.permissionDeniedMessage
            case .history:
                viewModel.notificationAlertMessage = String(localized: "settings.notification.historyPermissionDeniedMessage")
            case .dailyPerfume:
                viewModel.notificationAlertMessage = String(localized: "settings.notification.dailyPerfumePermissionDeniedMessage")
            }
            viewModel.showsNotificationSettingsAction = true
        case .profileUnavailable:
            viewModel.notificationAlertTitle = L10n.Settings.Notification.profileRequiredTitle
            viewModel.notificationAlertMessage = kind == .dailyPerfume
                ? String(localized: "settings.notification.dailyPerfumeProfileRequiredMessage")
                : L10n.Settings.Notification.profileRequiredMessage
            viewModel.showsNotificationSettingsAction = false
        }

        viewModel.isShowingNotificationAlert = true
    }

    @MainActor
    private func presentUnknownNotificationError(for kind: DailyNotificationKind) {
        viewModel.notificationAlertTitle = kind == .horoscope
            ? L10n.Settings.Notification.unavailableTitle
            : String(localized: "settings.notification.historyUnavailableTitle")
        viewModel.notificationAlertMessage = L10n.Common.Error.message
        viewModel.showsNotificationSettingsAction = false
        viewModel.isShowingNotificationAlert = true
    }
}
