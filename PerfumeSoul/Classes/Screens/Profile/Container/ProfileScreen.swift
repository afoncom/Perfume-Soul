//
//  ProfileScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ProfileScreen: View {
    @Bindable private var viewModel: ProfileViewMoodel
    private let presenter: ProfilePresenter

    
    init(
        viewModel: ProfileViewMoodel,
        presenter: ProfilePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                makeProfileScreen()
                    .padding(.horizontal, 16)
                
                makeMyNatalChart()
                    .padding(.horizontal, 16)
                
                makeElementBalance()
                    .padding(.horizontal, 16)
                
                makeAddedNewProfiless()
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
        .task {
            await presenter.onAppear()
        }
    }
}

private extension ProfileScreen {
    func makeProfileScreen() -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.16))
                .frame(width: 62, height: 62)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Anna Petrova")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(L10n.Profile.birthInfo)
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
                    color: Color.pink.opacity(0.25),
                    symbol: "circle.hexagongrid.fill",
                    symbolColor: .pink,
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
