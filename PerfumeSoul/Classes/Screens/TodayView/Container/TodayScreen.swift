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
    private let recommendedPerfumeScreen: RecommendedPerfumeScreen
    private let presenter: TodayPresenter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 38
    @ScaledMetric(relativeTo: .largeTitle) private var historyDateSize = 44

    init(
        viewModel: TodayViewModel,
        dailyPerfumeScreen: DailyPerfumeScreen,
        recommendedPerfumeScreen: RecommendedPerfumeScreen,
        presenter: TodayPresenter
    ) {
        self.viewModel = viewModel
        self.dailyPerfumeScreen = dailyPerfumeScreen
        self.recommendedPerfumeScreen = recommendedPerfumeScreen
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                PerfumeFlowHeader(section: viewModel.dateText, step: nil)
                    .padding(.horizontal, 24)

                TodayOverviewBanner()
                    .padding(.horizontal, 24)

                makeTodayEnergyCard()
                    .padding(.horizontal, 24)

                dailyPerfumeScreen
                    .padding(.horizontal, 24)

                recommendedPerfumeScreen

                makeHistorySection()
                    .padding(.horizontal, 24)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.backgroundPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await presenter.onAppear()
        }
    }
}

extension TodayScreen {
    private func makeTodayEnergyCard() -> some View {
        Button {
            presenter.todayEnergyButtonTab()
        } label: {
            VStack(alignment: .leading, spacing: 28) {
                Text(L10n.Today.Energy.title.uppercased())
                    .font(.caption.weight(.medium))
                    .tracking(1.2)

                if let horoscope = viewModel.personalHoroscope {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(horoscope.displayName)
                            .font(.system(size: headingSize, weight: .medium))
                            .tracking(-1)
                            .accessibilityAddTraits(.isHeader)

                        Text(horoscope.energyOfDay)
                            .font(.body)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        Text(L10n.PerfumeFlow.readMore)
                            .font(.subheadline.weight(.medium))
                        Spacer(minLength: 0)
                        Image(systemName: "arrow.up.right")
                            .accessibilityHidden(true)
                    }
                    .padding(.top, 20)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color(.textPrimary).opacity(0.16))
                            .frame(height: 1)
                    }
                } else if case .loading = viewModel.viewState {
                    ProgressView()
                        .tint(Color(.textPrimary))
                        .frame(maxWidth: .infinity, minHeight: 160)
                } else {
                    Text(L10n.Today.Energy.missingProfile)
                        .font(.body)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .foregroundStyle(Color(.textPrimary))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
            .background {
                GeometryReader { geometry in
                    ZStack {
                        Image(.todayHoroscopePhoto)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .accessibilityHidden(true)

                        Color(.backgroundPrimary).opacity(0.82)
                    }
                }
            }
            .clipped()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.personalHoroscope == nil)
    }

    private func makeHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.Today.History.title)
                .font(.title2.weight(.semibold))
                .tracking(-0.5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .tint(Color(.textPrimary))
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .background(Color(.textPrimary).opacity(0.035))
            case let .loaded(historyFact):
                makeHistoryCard(historyFact: historyFact)
            }
        }
        .foregroundStyle(Color(.textPrimary))
    }

    private func makeHistoryCard(historyFact: PerfumeHistory) -> some View {
        Button {
            presenter.dayInPerfumeryButtonTab()
        } label: {
            VStack(alignment: .leading, spacing: 24) {
                Text(viewModel.historyDateText(year: historyFact.year))
                    .font(
                        dynamicTypeSize.isAccessibilitySize
                            ? .title.weight(.light)
                            : .system(size: historyDateSize, weight: .light)
                    )
                    .tracking(-1.2)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 1 : 0.7)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(Color(.inputBorder))
                    .frame(height: 1)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 14) {
                    Text(historyFact.perfumeName)
                        .font(.title2.weight(.medium))
                        .tracking(-0.4)

                    Text(historyFact.shortStory)
                        .font(.body)
                        .foregroundStyle(Color(.descriptionText))
                        .lineSpacing(4)
                }
                .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(L10n.PerfumeFlow.readMore)
                        .font(.subheadline.weight(.medium))
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .accessibilityHidden(true)
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.textPrimary).opacity(0.035))
            .multilineTextAlignment(.leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TodayOverviewBanner: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 32

    var body: some View {
        Group {
            if dynamicTypeSize >= .xLarge {
                bannerText
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.textPrimary).opacity(0.035))
            } else {
                GeometryReader { geometry in
                    Image(.todayOverviewPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .accessibilityHidden(true)
                        .overlay(alignment: .leading) {
                            bannerText
                                .frame(width: geometry.size.width * 0.52, alignment: .leading)
                                .padding(.leading, 20)
                        }
                }
                .aspectRatio(1.65, contentMode: .fit)
            }
        }
        .foregroundStyle(Color(.textPrimary))
    }

    private var bannerText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Overview.caption.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.7)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.Today.Overview.title)
                .font(.system(size: titleSize, weight: .semibold))
                .tracking(-1.4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension TodayScreen {
    enum ViewState {
        case loading
        case loaded(historyFact: PerfumeHistory)
    }
}
