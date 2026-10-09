//
//  ProfileDescriptionScreen.swift
//  PerfumeSoul
//

import SwiftUI

struct ProfileDescriptionScreen: View {
    @Bindable private var viewModel: ProfileDescriptionViewModel
    private let presenter: ProfileDescriptionPresenter
    @State private var selectedInsight: SelectedInsight?
    @State private var visibleInsightIndex: Int? = 0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 32
    @ScaledMetric(relativeTo: .title2) private var cardTitleSize = 24

    init(viewModel: ProfileDescriptionViewModel, presenter: ProfileDescriptionPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PerfumeFlowHeader(
                    section: L10n.PerfumeFlow.resultSection,
                    step: presenter.isPresentedInOnboarding ? 3 : nil
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .tint(Color(.textPrimary))
                        .frame(maxWidth: .infinity, minHeight: 300)
                case let .content(_, profileDescription):
                    makeResult(profileDescription)
                case .missingBirthPlaceData:
                    makeUnavailableState(
                        title: L10n.ProfileDescription.unavailableTitle,
                        message: L10n.ProfileDescription.unavailableMessage,
                        canRetry: false
                    )
                case .invalidBirthData:
                    makeUnavailableState(
                        title: L10n.ProfileDescription.invalidBirthDataTitle,
                        message: L10n.ProfileDescription.invalidBirthDataMessage,
                        canRetry: false
                    )
                case .failed:
                    makeUnavailableState(
                        title: L10n.ProfileDescription.failedTitle,
                        message: L10n.ProfileDescription.failedMessage,
                        canRetry: true
                    )
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.backgroundPrimary))
        .preferredColorScheme(.light)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if presenter.shouldShowContinueButton {
                PerfumePrimaryButton(title: L10n.PerfumeFlow.findPerfumes) {
                    presenter.continueButtonTapped()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.backgroundPrimary).ignoresSafeArea(edges: .bottom))
            }
        }
        .sheet(item: $selectedInsight) { selection in
            makeInsightDetail(selection)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.backgroundPrimary))
        }
        .task {
            await presenter.onAppear()
        }
    }
}

extension ProfileDescriptionScreen {
    private struct SelectedInsight: Identifiable {
        let index: Int
        let insight: ProfileDescriptionInsight

        var id: Int { index }
    }

    private func makeResult(_ profileDescription: ProfileDescription) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            makeHeader(profileDescription)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.PerfumeFlow.summaryTitle.uppercased())
                    .font(.caption.weight(.medium))
                    .tracking(0.8)
                    .foregroundStyle(Color(.descriptionText))

                Text(profileDescription.summary)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color(.textPrimary).opacity(0.035))
            .padding(.horizontal, 24)
            .padding(.top, 26)

            HStack(alignment: .firstTextBaseline) {
                Text(L10n.PerfumeFlow.insightsTitle)
                    .font(.title2.weight(.semibold))
                    .tracking(-0.4)

                Spacer()

                Text(String(format: "%02d", profileDescription.insights.count))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color(.descriptionText))
            }
            .foregroundStyle(Color(.textPrimary))
            .padding(.horizontal, 24)
            .padding(.top, 34)

            Text(L10n.ProfileDescription.headerHint)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 20)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    ForEach(Array(profileDescription.insights.enumerated()), id: \.offset) { index, insight in
                        makeInsightCard(insight, index: index, isCompact: false)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                makeInsightCarousel(profileDescription)
            }
        }
    }

    private func makeHeader(_ profileDescription: ProfileDescription) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let name = viewModel.profile?.name, !name.isEmpty {
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
            }

            Text(profileDescription.title)
                .font(.system(size: headingSize, weight: .semibold))
                .tracking(-0.8)
                .foregroundStyle(Color(.textPrimary))
                .fixedSize(horizontal: false, vertical: true)

            Text(profileDescription.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeInsightCarousel(_ profileDescription: ProfileDescription) -> some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(profileDescription.insights.enumerated()), id: \.offset) { index, insight in
                        makeInsightCard(insight, index: index, isCompact: true)
                            .id(index)
                            .scrollTransition(.interactive, axis: .horizontal) { [reduceMotion] content, phase in
                                content
                                    .opacity(reduceMotion || phase.isIdentity ? 1 : 0.7)
                                    .scaleEffect(reduceMotion || phase.isIdentity ? 1 : 0.98)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 24, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $visibleInsightIndex, anchor: .leading)

            HStack {
                Text(L10n.PerfumeFlow.swipeHint)
                Spacer()
                Text(String(format: "%02d / %02d", (visibleInsightIndex ?? 0) + 1, profileDescription.insights.count))
                    .monospacedDigit()
            }
            .font(.caption)
            .foregroundStyle(Color(.descriptionText))
            .padding(.horizontal, 24)
        }
    }

    private func makeInsightCard(_ insight: ProfileDescriptionInsight, index: Int, isCompact: Bool) -> some View {
        Button {
            selectedInsight = SelectedInsight(index: index, insight: insight)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.insightCategory(for: insight.style).uppercased())
                        .tracking(0.6)

                    Spacer(minLength: 8)

                    Text(String(format: "%02d", index + 1))
                        .monospacedDigit()
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color(.descriptionText))

                Text(insight.title)
                    .font(.system(size: cardTitleSize, weight: .semibold))
                    .tracking(-0.5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(insight.description)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
                    .lineLimit(isCompact ? 3 : nil)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Rectangle()
                    .fill(Color(.inputBorder))
                    .frame(height: 1)

                HStack {
                    Text(L10n.PerfumeFlow.readMore)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.subheadline)
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(Color(.textPrimary))
            .padding(20)
            .frame(width: isCompact ? 280 : nil)
            .frame(maxWidth: isCompact ? nil : .infinity, minHeight: 270)
            .background(Color(.backgroundPrimary))
            .overlay {
                Rectangle().stroke(Color(.inputBorder), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(L10n.PerfumeFlow.readMore)
    }

    private func makeInsightDetail(_ selection: SelectedInsight) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(viewModel.insightCategory(for: selection.insight.style).uppercased())
                        .font(.caption.weight(.medium))
                        .tracking(0.8)
                        .foregroundStyle(Color(.descriptionText))

                    Spacer()

                    Button {
                        selectedInsight = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.ProfileDescription.closeCard)
                }

                Rectangle()
                    .fill(Color(.inputBorder))
                    .frame(height: 1)
                    .padding(.top, 8)

                Text(selection.insight.title)
                    .font(.system(size: headingSize, weight: .semibold))
                    .tracking(-0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 32)

                Text(selection.insight.description)
                    .font(.body)
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(5)
                    .padding(.top, 22)
            }
            .foregroundStyle(Color(.textPrimary))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.backgroundPrimary))
    }

    private func makeUnavailableState(title: String, message: String, canRetry: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: headingSize, weight: .semibold))
                .foregroundStyle(Color(.textPrimary))

            Text(message)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)

            if canRetry {
                PerfumePrimaryButton(title: L10n.ProfileDescription.retryButton) {
                    Task {
                        await presenter.retryButtonTapped()
                    }
                }
                .padding(.top, 16)
            }

            if presenter.isPresentedInOnboarding {
                Button {
                    presenter.skipButtonTapped()
                } label: {
                    Text(L10n.ProfileDescription.skipButton)
                        .font(.body)
                        .foregroundStyle(Color(.textPrimary))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
