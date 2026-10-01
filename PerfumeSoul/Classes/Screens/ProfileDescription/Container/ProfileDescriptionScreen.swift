//
//  ProfileDescriptionScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

private struct ProfileDescriptionCardSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ProfileDescriptionScreen: View {
    @Bindable private var viewModel: ProfileDescriptionViewModel
    private let presenter: ProfileDescriptionPresenter
    @State private var selectedInsightIndex: Int?
    @State private var selectedCardFrame: CGRect = .zero
    @State private var expandedCardSize: CGSize = .zero
    @State private var isWaitingForCardHeight = false
    @State private var isCardExpanded = false
    @State private var isFrontContentVisible = true
    @State private var isCardRevealed = false
    @State private var isCardAnimating = false
    @State private var cardRotation = 0.0
    
    init(
        viewModel: ProfileDescriptionViewModel,
        presenter: ProfileDescriptionPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        let bottomPadding = presenter.shouldShowContinueButton ? 96.0 : 32.0

        GeometryReader { geometry in
            ZStack {
                makeContentView(bottomPadding: bottomPadding)

                if case let .content(_, profileDescription) = viewModel.state,
                    let selectedInsightIndex,
                    profileDescription.insights.indices.contains(selectedInsightIndex) {
                    makeExpandedCard(profileDescription.insights[selectedInsightIndex], in: geometry.size)
                        .zIndex(1)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .coordinateSpace(name: "profileDescription")
        }
        .background {
            Image(.profileDescriptionBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            if presenter.shouldShowContinueButton {
                makeContinueButton()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .opacity(selectedInsightIndex == nil ? 1 : 0)
                    .allowsHitTesting(selectedInsightIndex == nil)
            }
        }
        .task {
            await presenter.onAppear()
        }
    }
}

extension ProfileDescriptionScreen {
    @ViewBuilder
    private func makeContentView(bottomPadding: Double) -> some View {
        switch viewModel.state {
        case .idle, .loading:
            makeLoadingState()
        case let .content(_, profileDescription):
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    makeHeaderView(profileDescription: profileDescription)
                    makeInsightCards(profileDescription: profileDescription)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, bottomPadding)
            }
            .scrollDisabled(selectedInsightIndex != nil)
        case .missingBirthPlaceData:
            makeUnavailableState(
                title: L10n.ProfileDescription.unavailableTitle,
                message: L10n.ProfileDescription.unavailableMessage,
                canRetry: false,
                canSkip: presenter.isPresentedInOnboarding
            )
            .padding(.horizontal, 24)
        case .invalidBirthData:
            makeUnavailableState(
                title: L10n.ProfileDescription.invalidBirthDataTitle,
                message: L10n.ProfileDescription.invalidBirthDataMessage,
                canRetry: false,
                canSkip: presenter.isPresentedInOnboarding
            )
            .padding(.horizontal, 24)
        case .failed:
            makeUnavailableState(
                title: L10n.ProfileDescription.failedTitle,
                message: L10n.ProfileDescription.failedMessage,
                canRetry: true,
                canSkip: presenter.isPresentedInOnboarding
            )
            .padding(.horizontal, 24)
        }
    }

    private func makeHeaderView(profileDescription: ProfileDescription) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = viewModel.profile?.name {
                Text(name)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(Color(.descriptionText))
            }

            Text(profileDescription.title)
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Rectangle()
                .fill(Color(.descriptionText).opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 10)

            Text(L10n.ProfileDescription.headerHint)
                .font(.system(size: 15))
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func makeInsightCards(profileDescription: ProfileDescription) -> some View {
        VStack(spacing: 14) {
            ForEach(Array(profileDescription.insights.enumerated()), id: \.offset) { index, insight in
                GeometryReader { geometry in
                    Button {
                        openCard(at: index, frame: geometry.frame(in: .named("profileDescription")))
                    } label: {
                        makeInsightCard(insight)
                    }
                    .buttonStyle(.plain)
                    .opacity(selectedInsightIndex == index ? 0 : 1)
                    .disabled(selectedInsightIndex != nil)
                }
                .frame(height: 112)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func makeInsightCard(_ insight: ProfileDescriptionInsight) -> some View {
        ZStack(alignment: .leading) {
            ZStack {
                Circle()
                    .fill(Color(.rowBackground))
                    .frame(width: 64, height: 64)
                
                Image(systemName: insight.iconSystemName)
                    .font(.system(size: 27, weight: .light))
                    .foregroundStyle(Color(.textPrimary))
            }
            .frame(width: 64, height: 64)
            .padding(.leading, 16)

            Text(insight.title)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 82)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.glassBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadow), radius: 22, x: 0, y: 12)
    }

    private func makeExpandedCard(_ insight: ProfileDescriptionInsight, in size: CGSize) -> some View {
        let expandedWidth = min(size.width - 48, 430)
        let cardWidth = isCardExpanded ? expandedWidth : selectedCardFrame.width
        let cardHeight = isCardExpanded ? expandedCardSize.height : selectedCardFrame.height

        return ZStack {
            Color(.textPrimary).opacity(isCardExpanded ? 0.42 : 0)
                .ignoresSafeArea()

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.surfacePrimary))

                makeInsightCard(insight)
                    .opacity(isFrontContentVisible ? 1 : 0)

                ScrollView(.vertical, showsIndicators: false) {
                    makeCardBackContent(insight)
                }
                .frame(width: cardWidth, height: cardHeight)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isCardRevealed ? 1 : 0)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(.glassBorder), lineWidth: 1)
            )
            .shadow(color: Color(.cardShadow), radius: 24, x: 0, y: 14)
            .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
            .position(
                x: isCardExpanded ? size.width / 2 : selectedCardFrame.midX,
                y: isCardExpanded ? size.height / 2 : selectedCardFrame.midY
            )
        }
        .frame(width: size.width, height: size.height)
        .accessibilityAction(.escape) {
            closeCard()
        }
        .background {
            makeCardBackContent(insight)
                .frame(width: expandedWidth)
                .fixedSize(horizontal: false, vertical: true)
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ProfileDescriptionCardSizeKey.self, value: geometry.size)
                    }
                }
                .hidden()
                .accessibilityHidden(true)
        }
        .onPreferenceChange(ProfileDescriptionCardSizeKey.self) { measuredSize in
            if measuredSize.height > 0 {
                expandedCardSize.height = min(size.height - 32, max(112, measuredSize.height))
                if isWaitingForCardHeight {
                    isWaitingForCardHeight = false
                    animateOpeningCard()
                }
            }
        }
    }

    private func makeCardBackContent(_ insight: ProfileDescriptionInsight) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: insight.iconSystemName)
                    .font(.system(size: 32, weight: .light))

                Text(insight.title)
                    .font(.system(size: 32, weight: .regular, design: .serif))
            }
            .padding(.trailing, 40)

            Rectangle()
                .fill(Color(.descriptionText).opacity(0.25))
                .frame(height: 1)

            Text(insight.description)
                .font(.system(size: 18))
                .foregroundStyle(Color(.descriptionText))
        }
        .foregroundStyle(Color(.textPrimary))
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button {
                closeCard()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Color(.textPrimary))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color(.descriptionText).opacity(0.5), lineWidth: 1)
                    )
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(isCardAnimating)
            .accessibilityLabel(L10n.ProfileDescription.closeCard)
            .padding(.top, 14)
            .padding(.trailing, 14)
        }
    }

    private func openCard(at index: Int, frame: CGRect) {
        guard selectedInsightIndex == nil else {
            return
        }

        selectedCardFrame = frame
        expandedCardSize = .zero
        isCardAnimating = true
        isWaitingForCardHeight = true
        selectedInsightIndex = index
    }

    private func animateOpeningCard() {
        Task { @MainActor in
            withAnimation(.easeInOut(duration: 1.45)) {
                isCardExpanded = true
                cardRotation = 900
            }
            withAnimation(.easeOut(duration: 0.2)) {
                isFrontContentVisible = false
            }
            try? await Task.sleep(for: .milliseconds(1250))
            withAnimation(.easeIn(duration: 0.2)) {
                isCardRevealed = true
            }
            try? await Task.sleep(for: .milliseconds(200))
            isCardAnimating = false
        }
    }

    private func closeCard() {
        guard !isCardAnimating else {
            return
        }

        isCardAnimating = true
        withAnimation(.easeOut(duration: 0.2)) {
            isCardRevealed = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.easeInOut(duration: 1.35)) {
                isCardExpanded = false
                cardRotation = 1800
            }
            try? await Task.sleep(for: .milliseconds(1350))
            selectedInsightIndex = nil
            isFrontContentVisible = true
            cardRotation = 0
            isCardAnimating = false
        }
    }

    private func makeLoadingState() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func makeUnavailableState(
        title: String,
        message: String,
        canRetry: Bool,
        canSkip: Bool
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(.pinkIcon))

            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.titleText))

            Text(message)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if canRetry {
                Button {
                    Task {
                        await presenter.retryButtonTapped()
                    }
                } label: {
                    Text(L10n.ProfileDescription.retryButton)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.textPrimary))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color(.surfacePrimary))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.cardBorder), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            if canSkip {
                Button {
                    presenter.skipButtonTapped()
                } label: {
                    Text(L10n.ProfileDescription.skipButton)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.textOnAccent))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color(.pinkButton))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text(L10n.Common.continueButton)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(.backgroundPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.textPrimary))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.55)
        .background(Color(.surfaceHighlight))
    }
}
