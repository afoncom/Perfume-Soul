//
//  TodayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct TodayScreen: View {
    @Bindable private var viewModel: TodayViewModel
    private let presenter: TodayPresenter
    
    init(
        viewModel: TodayViewModel,
        presenter: TodayPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                makeTodayEnergyScreen()
                    .padding(.horizontal, 16)
                
                makeAromaDay()
                    .padding(.horizontal, 16)
                
                makeRecommendedForYou()
                    .padding(.horizontal, 16)
                
                makeThisDayInPerfumery()
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }
}

private extension TodayScreen {
    func makeTodayEnergyScreen() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Energy.title)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Circle()
                    .fill(.surfacePrimary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(.pinkButton, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Today.Energy.moonTitle)
                        .font(.headline)
                    
                    Text(L10n.Today.Energy.description)
                        .font(.footnote)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
            }
        }
        .padding(14)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .cardShadow, radius: 10, x: 0, y: 4)
        .onTapGesture {
            presenter.todayEnergyButtonTab()
        }
    }
    
    func makeAromaDay() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Aroma.title)
                .font(.title3)
                .fontWeight(.medium)
            
            
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tom Ford\nOud Wood")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(L10n.Today.Aroma.tags)
                        .font(.footnote)
                        .foregroundStyle(.textSecondary)
                    
                    HStack(spacing: 6) {
                        Button(action: {}) {
                            Text(L10n.Today.Aroma.primaryAction)
                                .font(.caption)
                                .foregroundStyle(.textOnAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(.pinkButton)
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {}) {
                            Text(L10n.Today.Aroma.secondaryAction)
                                .font(.caption)
                                .foregroundStyle(.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(.secondaryButtonBackground)
                                .overlay(
                                    Capsule()
                                        .stroke(.secondaryButtonBorder, lineWidth: 1)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.placeholderMedium)
                    .frame(width: 82, height: 112)
            }
        }
        .padding(16)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .cardShadow, radius: 10, x: 0, y: 4)
    }
    
    func makeRecommendedForYou() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Recommended.title)
                .font(.title3)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<8, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.placeholderMedium)
                                .frame(width: 84, height: 96)
                            
                            Text("Byredo")
                                .font(.subheadline)
                                .foregroundStyle(.textPrimary)
                                .lineLimit(1)
                            
                            Text("Gypsy Water")
                                .font(.caption)
                                .foregroundStyle(.textSecondary)
                                .lineLimit(1)
                        }
                        .padding(10)
                        .frame(width: 104, alignment: .leading)
                        .background(.surfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .cardShadowSoft, radius: 8, x: 0, y: 3)
                    }
                    
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    func makeThisDayInPerfumery() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.History.title)
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("1957")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(L10n.Today.History.eventTitle)
                        .font(.title3)
                        .foregroundStyle(.textPrimary)
                }
                
                Text(L10n.Today.History.description)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .cardShadow, radius: 10, x: 0, y: 4)
        }
        .onTapGesture {
            presenter.dayInPerfumeryButtonTab()
        }
    }
}
