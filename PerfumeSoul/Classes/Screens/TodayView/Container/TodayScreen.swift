//
//  TodayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct TodayScreen: View {
    @Bindable private var viewModel: TodayViewModel
    private let dailyPerfumeScreen: DailyPerfumeScreen
    private let presenter: TodayPresenter
    
    init(
        viewModel: TodayViewModel,
        dailyPerfumeScreen: DailyPerfumeScreen,
        presenter: TodayPresenter
    ) {
        self.viewModel = viewModel
        self.dailyPerfumeScreen = dailyPerfumeScreen
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
        .task {
            await presenter.onAppear()
        }
    }
}

extension TodayScreen {
    private func makeTodayEnergyScreen() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Energy.title)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color(.surfacePrimary))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(viewModel.personalHoroscope?.iconColor ?? Color(.pinkButton), lineWidth: 1)
                    )
                    .overlay(
                        Text(viewModel.personalHoroscope?.symbol ?? "✦")
                            .font(.headline)
                            .foregroundStyle(viewModel.personalHoroscope?.iconColor ?? Color(.pinkButton))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.personalHoroscope?.displayName ?? "")
                        .font(.headline)
                    
                    Text(viewModel.personalHoroscope?.energyOfDay ?? "")
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadow), radius: 10, x: 0, y: 4)
        .onTapGesture {
            presenter.todayEnergyButtonTab()
        }
    }
    
    private func makeAromaDay() -> some View {
        dailyPerfumeScreen
    }
    
    private func makeRecommendedForYou() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Recommended.title)
                .font(.title3)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<8, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.placeholderMedium))
                                .frame(width: 84, height: 96)
                            
                            Text("Byredo")
                                .font(.subheadline)
                                .foregroundStyle(Color(.textPrimary))
                                .lineLimit(1)
                            
                            Text("Gypsy Water")
                                .font(.caption)
                                .foregroundStyle(Color(.textSecondary))
                                .lineLimit(1)
                        }
                        .padding(10)
                        .frame(width: 104, alignment: .leading)
                        .background(Color(.surfacePrimary))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color(.cardShadowSoft), radius: 8, x: 0, y: 3)
                    }
                    
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func makeThisDayInPerfumery() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.History.title)
                .font(.title3)
                .fontWeight(.medium)
            
            switch viewModel.viewState {
            case .loading:
                makeHistoryFactLoadingCard()
            case let .loaded(historyFact):
                makeHistoryFactCard(historyFact: historyFact)
            }
        }
        .onTapGesture {
            presenter.dayInPerfumeryButtonTab()
        }
    }
    
    private func makeHistoryFactCard(historyFact: PerfumeHistory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(historyFact.year))
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(historyFact.perfumeName)
                    .font(.title3)
                    .foregroundStyle(Color(.textPrimary))
            }
            
            Text(historyFact.shortStory)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(.cardShadow), radius: 10, x: 0, y: 4)
    }
    
    private func makeHistoryFactLoadingCard() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(.placeholderMedium))
                    .frame(width: 52, height: 28)
                
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(.placeholderMedium))
                    .frame(width: 164, height: 24)
            }
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 18)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(.placeholderSoft))
                .frame(width: 220, height: 18)
        }
        .redacted(reason: .placeholder)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(.cardShadow), radius: 10, x: 0, y: 4)
    }
}

extension TodayScreen {
    enum ViewState {
        case loading
        case loaded(historyFact: PerfumeHistory)
    }
}
