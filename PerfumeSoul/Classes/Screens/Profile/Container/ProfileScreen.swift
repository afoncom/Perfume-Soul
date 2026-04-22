//
//  ProfileScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ProfileScreen: View {
    @Bindable private var viewModel: ProfileViewModel
    private let presenter: ProfilePresenter
    
    init(
        viewModel: ProfileViewModel,
        presenter: ProfilePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ZStack {
            if let profile = viewModel.profile {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        makeProfileScreen(profile: profile)
                            .padding(.horizontal, 16)
                        
                        makeMyNatalChart()
                            .padding(.horizontal, 16)
                        
                        makeElementBalance()
                            .padding(.horizontal, 16)

                        makePersonalPerfumesRow()
                            .padding(.horizontal, 16)
                        
                        makeAddedNewProfiless()
                            .padding(.horizontal, 16)
                        
                        makeDeleteProfileAction()
                            .padding(.horizontal, 16)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(
            L10n.Profile.Actions.deleteAlertTitle,
            isPresented: $viewModel.isShowingDeleteProfileAlert
        ) {
            Button(L10n.Profile.Actions.cancelButton, role: .cancel) { }
            Button(L10n.Profile.Actions.deleteButton, role: .destructive) {
                Task {
                    await presenter.deleteProfile()
                }
            }
        } message: {
            Text(L10n.Profile.Actions.deleteAlertMessage)
        }
        .task {
            await presenter.onAppear()
        }
    }
}

private extension ProfileScreen {
    func makeProfileScreen(profile: Profile) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.placeholderStrong)
                .frame(width: 62, height: 62)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(makeProfileBirthInfo(profile: profile))
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func makeMyNatalChart() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Profile.NatalChart.title)
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                makeNatalChartRow(
                    color: .natalSunSurface,
                    symbol: "sun.max.fill",
                    symbolColor: .natalSunAccent,
                    title: L10n.Profile.NatalChart.sun,
                    value: L10n.Profile.NatalChart.sunValue
                )
                
                makeNatalChartRow(
                    color: .natalMoonSurface,
                    symbol: "moon.fill",
                    symbolColor: .natalMoonAccent,
                    title: L10n.Profile.NatalChart.moon,
                    value: L10n.Profile.NatalChart.moonValue
                )
                
                makeNatalChartRow(
                    color: .natalAscendantSurface,
                    symbol: "circle.hexagongrid.fill",
                    symbolColor: .pinkButton,
                    title: L10n.Profile.NatalChart.ascendant,
                    value: L10n.Profile.NatalChart.ascendantValue
                )
            }
        }
        .padding(14)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .cardShadowSubtle, radius: 7, x: 0, y: 3)
    }
    
    func makeElementBalance() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Profile.ElementBalance.title)
                .font(.title3)
                .fontWeight(.medium)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.placeholderSoft)
                    .frame(height: 34)
            }
            
            HStack {
                makeElementItem(percent: "15%", title: L10n.Profile.Element.fire)
                Spacer()
                makeElementItem(percent: "40%", title: L10n.Profile.Element.earth)
                Spacer()
                makeElementItem(percent: "15%", title: L10n.Profile.Element.air)
                Spacer()
                makeElementItem(percent: "30%", title: L10n.Profile.Element.water)
            }
        }
        .padding(14)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .cardShadowSubtle, radius: 7, x: 0, y: 3)
    }

    func makePersonalPerfumesRow() -> some View {
        Button {
            presenter.personalPerfumesButtonTapped()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.purpleTable.opacity(0.18))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundStyle(.purpleIcon)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Perfumes")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.textPrimary)
                    
                    Text("Open your curated fragrance selection.")
                        .font(.footnote)
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.cardBorder, lineWidth: 1)
            )
            .shadow(color: .cardShadowSubtle, radius: 7, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
    
    func makeAddedNewProfiless() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Profile.Profiles.title)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    presenter.addedNewProfilesButtonTab()
                }) {
                    Image(systemName: "plus")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(.textSecondary)
                        .frame(width: 28, height: 28)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    makeAddedProfileItem(name: "Laura")
                    makeAddedProfileItem(name: "Alex")
                    makeAddedProfileItem(name: "Ada")
                }
            }
        }
        .padding(14)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .cardShadowSubtle, radius: 7, x: 0, y: 3)
    }
    
    func makeDeleteProfileAction() -> some View {
        Button {
            viewModel.isShowingDeleteProfileAlert = true
        } label: {
            Text(L10n.Profile.Actions.deleteButton)
                .font(.headline)
                .foregroundStyle(.destructiveAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.destructiveSurface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    func makeProfileBirthInfo(profile: Profile) -> String {
        return [profile.birthDate, profile.birthTime, profile.birthPlace]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

//MARK: - Natal Chart Row

private extension ProfileScreen {
    func makeNatalChartRow(
        color: Color,
        symbol: String,
        symbolColor: Color,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: symbol)
                        .font(.headline)
                        .foregroundColor(symbolColor)
                )
            
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

//MARK: - Element Item

private extension ProfileScreen {
    func makeElementItem(percent: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(percent)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.textSecondary)
        }
    }
}

//MARK: - Added Profile Item

private extension ProfileScreen {
    func makeAddedProfileItem(name: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.placeholderMedium)
                .frame(width: 92, height: 92)
            
            Text(name)
                .font(.headline)
                .foregroundStyle(.textPrimary)
        }
    }
}
