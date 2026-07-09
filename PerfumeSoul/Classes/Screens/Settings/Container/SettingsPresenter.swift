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
    func feedbackButtonTapped()
    func openSystemSettingsTapped()
    func notificationAlertDismissed()
}

final class SettingsPresenterImpl {
    private let viewModel: SettingsViewModel
    private let router: SettingsRouter
    private let dailyHoroscopeNotificationService: DailyHoroscopeNotificationService
    private var notificationToggleTask: Task<Void, Never>?
    
    init(
        viewModel: SettingsViewModel,
        router: SettingsRouter,
        dailyHoroscopeNotificationService: DailyHoroscopeNotificationService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.dailyHoroscopeNotificationService = dailyHoroscopeNotificationService
    }
}

extension SettingsPresenterImpl: SettingsPresenter {
    @MainActor
    func onAppear() async {
        viewModel.isDailyHoroscopeNotificationEnabled = dailyHoroscopeNotificationService.isDailyHoroscopeNotificationEnabled()
    }

    func dailyHoroscopeNotificationToggled(isEnabled: Bool) {
        viewModel.isDailyHoroscopeNotificationEnabled = isEnabled
        notificationToggleTask?.cancel()

        notificationToggleTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            if isEnabled {
                do {
                    try await dailyHoroscopeNotificationService.enableDailyHoroscopeNotification()
                    guard !Task.isCancelled else {
                        return
                    }

                    viewModel.isDailyHoroscopeNotificationEnabled = true
                } catch let error as DailyHoroscopeNotificationServiceError {
                    guard !Task.isCancelled else {
                        return
                    }

                    viewModel.isDailyHoroscopeNotificationEnabled = false
                    presentNotificationError(error)
                } catch {
                    guard !Task.isCancelled else {
                        return
                    }

                    viewModel.isDailyHoroscopeNotificationEnabled = false
                    presentUnknownNotificationError()
                }
            } else {
                await dailyHoroscopeNotificationService.disableDailyHoroscopeNotification()
                guard !Task.isCancelled else {
                    return
                }

                viewModel.isDailyHoroscopeNotificationEnabled = false
            }
        }
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

private extension SettingsPresenterImpl {
    @MainActor
    func presentNotificationError(_ error: DailyHoroscopeNotificationServiceError) {
        switch error {
        case .permissionDenied:
            viewModel.notificationAlertTitle = L10n.Settings.Notification.permissionDeniedTitle
            viewModel.notificationAlertMessage = L10n.Settings.Notification.permissionDeniedMessage
            viewModel.showsNotificationSettingsAction = true
        case .profileUnavailable:
            viewModel.notificationAlertTitle = L10n.Settings.Notification.profileRequiredTitle
            viewModel.notificationAlertMessage = L10n.Settings.Notification.profileRequiredMessage
            viewModel.showsNotificationSettingsAction = false
        }

        viewModel.isShowingNotificationAlert = true
    }

    @MainActor
    func presentUnknownNotificationError() {
        viewModel.notificationAlertTitle = L10n.Settings.Notification.unavailableTitle
        viewModel.notificationAlertMessage = L10n.Common.Error.message
        viewModel.showsNotificationSettingsAction = false
        viewModel.isShowingNotificationAlert = true
    }
}
