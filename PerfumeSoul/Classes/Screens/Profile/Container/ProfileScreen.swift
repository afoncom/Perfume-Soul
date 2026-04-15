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

                        makePersonalPerfumeSelection()
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
                .fill(Color.gray.opacity(0.16))
                .frame(width: 62, height: 62)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(makeProfileBirthInfo(profile: profile))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                    color: Color.orange.opacity(0.25),
                    symbol: "sun.max.fill",
                    symbolColor: .orange,
                    title: L10n.Profile.NatalChart.sun,
                    value: L10n.Profile.NatalChart.sunValue
                )
                
                makeNatalChartRow(
                    color: Color.blue.opacity(0.25),
                    symbol: "moon.fill",
                    symbolColor: .blue,
                    title: L10n.Profile.NatalChart.moon,
                    value: L10n.Profile.NatalChart.moonValue
                )
                
                makeNatalChartRow(
                    color: Color.pinkButton.opacity(0.25),
                    symbol: "circle.hexagongrid.fill",
                    symbolColor: .pinkButton,
                    title: L10n.Profile.NatalChart.ascendant,
                    value: L10n.Profile.NatalChart.ascendantValue
                )
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 7, x: 0, y: 3)
    }
    
    func makeElementBalance() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Profile.ElementBalance.title)
                .font(.title3)
                .fontWeight(.medium)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.gray.opacity(0.08))
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 7, x: 0, y: 3)
    }

    func makePersonalPerfumeSelection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Personal Perfume Wardrobe")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("A quick view of the scents selected for your vibe.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 14) {
                ForEach(Array(viewModel.personalPerfumeSections.enumerated()), id: \.offset) { _, section in
                    makePersonalPerfumeSection(section: section)
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color.purpleTable.opacity(0.72),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.purpleIcon.opacity(0.08), radius: 12, x: 0, y: 6)
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
                        .foregroundStyle(.secondary)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 7, x: 0, y: 3)
    }
    
    func makeDeleteProfileAction() -> some View {
        Button {
            viewModel.isShowingDeleteProfileAlert = true
        } label: {
            Text(L10n.Profile.Actions.deleteButton)
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    func makeProfileBirthInfo(profile: Profile) -> String {
        return [profile.birthDate, profile.birthTime, profile.birthPlace]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    func makePersonalPerfumeSection(section: PersonalPerfumeSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.88))
                    .clipShape(Capsule())
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(section.perfumes.enumerated()), id: \.offset) { _, perfume in
                        makePersonalPerfumeItem(perfume)
                    }
                }
            }
            
            Text(section.description)
                .font(.footnote)
                .foregroundStyle(Color.black.opacity(0.56))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    func makePersonalPerfumeItem(_ perfume: PersonalPerfumeItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.purpleTable.opacity(0.78)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 86, height: 94)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.purpleIcon.opacity(0.78))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(perfume.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black.opacity(0.82))
                    .lineLimit(1)
                
                Text(perfume.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 86, alignment: .topLeading)
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
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.06))
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
                .foregroundStyle(.secondary)
        }
    }
}

//MARK: - Added Profile Item

private extension ProfileScreen {
    func makeAddedProfileItem(name: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray.opacity(0.12))
                .frame(width: 92, height: 92)
            
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
}
