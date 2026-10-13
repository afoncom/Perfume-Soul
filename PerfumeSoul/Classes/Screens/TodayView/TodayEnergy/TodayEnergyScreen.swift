//
//  TodayEnergyScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct TodayEnergyScreen: View {
    @Bindable private var viewModel: TodayEnergyViewModel
    private let presenter: TodayEnergyPresenter
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 38

    init(
        viewModel: TodayEnergyViewModel,
        presenter: TodayEnergyPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 36) {
                makePersonalSection()
                makeHoroscopeSection()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationTitle(L10n.Screen.todayEnergy)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension TodayEnergyScreen {
    private func makePersonalSection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.Today.Energy.personalTitle.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1.2)
                .foregroundStyle(Color(.descriptionText))

            Text(viewModel.personalDailyHoroscope.displayName)
                .font(.system(size: headingSize, weight: .medium))
                .tracking(-1)
                .accessibilityAddTraits(.isHeader)

            Rectangle()
                .fill(Color(.textPrimary))
                .frame(width: 40, height: 2)
                .accessibilityHidden(true)

            Text(viewModel.personalDailyHoroscope.energyOfDay)
                .font(.body)
                .lineSpacing(6)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.textPrimary).opacity(0.035))
    }

    private func makeHoroscopeSection() -> some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(L10n.Today.Energy.listTitle)
                .font(.title2.weight(.semibold))
                .tracking(-0.5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(viewModel.dailyHoroscopes, id: \.sign) { horoscope in
                    makeHoroscopeCard(horoscope)
                }
            }
        }
    }

    private func makeHoroscopeCard(_ horoscope: DailyHoroscope) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Rectangle()
                .fill(Color(.inputBorder))
                .frame(height: 1)
                .accessibilityHidden(true)

            Text(horoscope.displayName)
                .font(.title.weight(.medium))
                .tracking(-0.6)
                .accessibilityAddTraits(.isHeader)

            Text(horoscope.energyOfDay)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(6)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
