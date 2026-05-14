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
    private let presenter: SettingsPresenter

    @State private var dailyHoroscopeEnabled = true
    @State private var aromaOfTheDayEnabled = true
    @State private var dayInPerfumeryEnabled = false

    init(
        viewModel: SettingsViewModel,
        presenter: SettingsPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                makeHeaderView()
                makeNotificationsSection()
                makePrivacySection()
                makeSupportSection()
                makeAboutSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 28)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension SettingsScreen {
    func makeHeaderView() -> some View {
        Text(L10n.Screen.settings)
            .font(.system(size: 28, weight: .medium, design: .rounded))
            .foregroundStyle(Color(.titleText))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 2)
    }

    func makeNotificationsSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.Settings.notificationsTitle)

            VStack(spacing: 0) {
                makeToggleRow(
                    icon: "bell",
                    iconColor: Color(.pinkButton),
                    title: L10n.Settings.Notification.dailyHoroscopeTitle,
                    subtitle: L10n.Settings.Notification.dailyHoroscopeSubtitle,
                    isOn: $dailyHoroscopeEnabled
                )

                makeDivider()

                makeToggleRow(
                    icon: "sparkles",
                    iconColor: Color(.zodiacPurple),
                    title: L10n.Settings.Notification.aromaOfTheDayTitle,
                    subtitle: L10n.Settings.Notification.aromaOfTheDaySubtitle,
                    isOn: $aromaOfTheDayEnabled
                )

                makeDivider()

                makeToggleRow(
                    icon: "calendar",
                    iconColor: Color(.zodiacOrange),
                    title: L10n.Settings.Notification.dayInPerfumeryTitle,
                    subtitle: L10n.Settings.Notification.dayInPerfumerySubtitle,
                    isOn: $dayInPerfumeryEnabled
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color(.cardShadowSubtle), radius: 9, x: 0, y: 4)
        }
    }

    func makePrivacySection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.Settings.privacyTitle)

            VStack(spacing: 0) {
                makeActionRow(
                    icon: "shield",
                    iconColor: Color(.zodiacPurple),
                    title: L10n.Settings.Privacy.howDataIsUsedTitle,
                    subtitle: L10n.Settings.Privacy.howDataIsUsedSubtitle
                )

                makeDivider()

                makeActionRow(
                    icon: "trash",
                    iconColor: Color(.pinkButton),
                    title: L10n.Settings.Privacy.clearLocalDataTitle,
                    subtitle: L10n.Settings.Privacy.clearLocalDataSubtitle
                )

                makeDivider()

                makeActionRow(
                    icon: "person",
                    iconColor: Color(.zodiacOrange),
                    title: L10n.Settings.Privacy.deleteAllProfilesTitle,
                    subtitle: L10n.Settings.Privacy.deleteAllProfilesSubtitle
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color(.cardShadowSubtle), radius: 9, x: 0, y: 4)
        }
    }

    func makeSupportSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.Settings.supportTitle)

            VStack(spacing: 0) {
                makeActionRow(
                    icon: "heart.fill",
                    iconColor: Color(.pinkButton),
                    title: L10n.Settings.Support.supportDeveloperTitle,
                    subtitle: L10n.Settings.Support.supportDeveloperSubtitle
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color(.cardShadowSubtle), radius: 9, x: 0, y: 4)
        }
    }

    func makeAboutSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.Settings.aboutTitle)

            VStack(spacing: 0) {
                makeActionRow(
                    icon: "info.circle",
                    iconColor: Color(.zodiacPurple),
                    title: L10n.Settings.About.aboutAppTitle,
                    subtitle: L10n.Settings.About.aboutAppSubtitle
                )

                makeDivider()

                makeActionRow(
                    icon: "link",
                    iconColor: Color(.zodiacBlue),
                    title: L10n.Settings.About.contactDeveloperTitle,
                    subtitle: L10n.Settings.About.contactDeveloperSubtitle
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color(.cardShadowSubtle), radius: 9, x: 0, y: 4)
        }
    }

    func makeSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(.textPrimary))
            .padding(.horizontal, 4)
    }

    func makeToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            makeIconCircle(icon: icon, iconColor: iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.textPrimary))

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(.pinkButton))
        }
        .padding(.vertical, 14)
    }

    func makeActionRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            makeIconCircle(icon: icon, iconColor: iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.textPrimary))

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(Color(.textSecondary))
        }
        .padding(.vertical, 14)
    }

    func makeIconCircle(icon: String, iconColor: Color) -> some View {
        ZStack {
            Circle()
                .fill(Color(.surfaceOverlay))
                .frame(width: 50, height: 50)

            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(iconColor)
        }
    }

    func makeDivider() -> some View {
        Divider()
            .overlay(Color(.cardBorder))
            .padding(.leading, 64)
    }
}
