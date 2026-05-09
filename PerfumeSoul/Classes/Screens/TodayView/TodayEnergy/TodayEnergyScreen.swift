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
    
    init(
        viewModel: TodayEnergyViewModel,
        presenter: TodayEnergyPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makePersonalSection()
                makeHoroscopeSection()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.backgroundPrimary))
        .navigationTitle(L10n.Screen.todayEnergy)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension TodayEnergyScreen {
    func makePersonalSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Energy.personalTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            if let personalDailyHoroscope = viewModel.personalDailyHoroscope {
                makeInfoCard(
                    icon: personalDailyHoroscope.symbol,
                    iconColor: personalDailyHoroscope.iconColor,
                    title: personalDailyHoroscope.displayName,
                    subtitle: personalDailyHoroscope.energyOfDay
                )
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeHoroscopeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Energy.listTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(spacing: 10) {
                ForEach(viewModel.dailyHoroscopes, id: \.sign) { dailyHoroscope in
                    makeInfoCard(
                        icon: dailyHoroscope.symbol,
                        iconColor: dailyHoroscope.iconColor,
                        title: dailyHoroscope.displayName,
                        subtitle: dailyHoroscope.energyOfDay
                    )
                }
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeInfoCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 42, height: 42)
                
                Text(icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
    }
}
