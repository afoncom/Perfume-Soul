//
//  SettingsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
    @Bindable private var viewModel: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    private let presenter: SettingsPresenter

    init(viewModel: SettingsViewModel, presenter: SettingsPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(
                    get: { viewModel.isDailyHoroscopeNotificationEnabled },
                    set: { presenter.dailyHoroscopeNotificationToggled(isEnabled: $0) }
                )) {
                    Label(L10n.Settings.Notification.dailyHoroscopeTitle, systemImage: "bell")
                }
                .listRowBackground(Color(.backgroundPrimary))
            } header: {
                Text(L10n.Settings.notificationsTitle)
            } footer: {
                Text(L10n.Settings.Notification.dailyHoroscopeSubtitle)
            }

            Section(L10n.Settings.supportTitle) {
                Button {
                    presenter.feedbackButtonTapped()
                } label: {
                    HStack {
                        Label(L10n.Settings.About.feedbackTitle, systemImage: "envelope")
                        Spacer(minLength: 12)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(.textSecondary))
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(.backgroundPrimary))
            }

            Section {
                LabeledContent(String(localized: "settings.version"), value: viewModel.appVersion)
                    .listRowBackground(Color(.backgroundPrimary))
            } header: {
                Text(L10n.Settings.aboutTitle)
            } footer: {
                Text("PerfumeSoul")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .accessibilityHidden(true)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.placeholderSoft).ignoresSafeArea())
        .foregroundStyle(Color(.textPrimary))
        .tint(Color(.textPrimary))
        .preferredColorScheme(.light)
        .task { await presenter.onAppear() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await presenter.onAppear() }
            }
        }
        .alert(viewModel.notificationAlertTitle ?? "", isPresented: $viewModel.isShowingNotificationAlert) {
            if viewModel.showsNotificationSettingsAction {
                Button(L10n.Settings.Notification.openSettingsButton) {
                    presenter.openSystemSettingsTapped()
                    presenter.notificationAlertDismissed()
                }
            }
            Button(L10n.Settings.Notification.dismissButton, role: .cancel) {
                presenter.notificationAlertDismissed()
            }
        } message: {
            Text(viewModel.notificationAlertMessage ?? "")
        }
    }
}
