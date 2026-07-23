//
//  ProfileDescriptionScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ProfileDescriptionScreen: View {
    @Bindable private var viewModel: ProfileDescriptionViewModel
    private let presenter: ProfileDescriptionPresenter
    
    init(
        viewModel: ProfileDescriptionViewModel,
        presenter: ProfileDescriptionPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        let bottomPadding = presenter.shouldShowContinueButton ? 140.0 : 32.0

        ZStack {
            makeContentView(bottomPadding: bottomPadding)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if presenter.shouldShowContinueButton {
                makeContinueButton()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
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
                VStack(spacing: 26) {
                    makeHeaderView(profileDescription: profileDescription)
                    makeInsightCards(profileDescription: profileDescription)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, bottomPadding)
            }
        case .missingBirthPlaceData:
            makeUnavailableState(
                title: L10n.ProfileDescription.unavailableTitle,
                message: L10n.ProfileDescription.unavailableMessage,
                canRetry: false
            )
            .padding(.horizontal, 24)
        case .failed:
            makeUnavailableState(
                title: L10n.ProfileDescription.failedTitle,
                message: L10n.ProfileDescription.failedMessage,
                canRetry: true
            )
            .padding(.horizontal, 24)
        }
    }

    private func makeHeaderView(profileDescription: ProfileDescription) -> some View {
        VStack(spacing: 10) {
            Text(profileDescription.title)
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))
                .multilineTextAlignment(.center)
            
            Text(profileDescription.subtitle)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.bodyText))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(profileDescription.summary)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 6)
        }
        .padding(.top, 8)
    }
    
    private func makeInsightCards(profileDescription: ProfileDescription) -> some View {
        VStack(spacing: 14) {
            ForEach(Array(profileDescription.insights.enumerated()), id: \.offset) { _, insight in
                let colors = colors(for: insight.style)

                makeInsightCard(
                    symbol: insight.iconSystemName,
                    iconBackground: colors.background,
                    iconTint: colors.tint,
                    title: insight.title,
                    description: insight.description
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func makeInsightCard(
        symbol: String,
        iconBackground: Color,
        iconTint: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 42, height: 42)
                
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconTint)
            }
            .frame(width: 42, height: 42, alignment: .top)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 8)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color(.surfaceOverlay))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.glassBorder), lineWidth: 1)
        )
        .shadow(color: Color(.insightCardShadow), radius: 18, x: 0, y: 10)
    }

    private func makeLoadingState() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func makeUnavailableState(
        title: String,
        message: String,
        canRetry: Bool
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func colors(for style: ProfileDescriptionInsightStyle) -> (background: Color, tint: Color) {
        switch style {
        case .sun:
            (Color(.natalSunSurface), Color(.natalSunAccent))
        case .moon:
            (Color(.natalMoonSurface), Color(.natalMoonAccent))
        case .ascendant:
            (Color(.natalAscendantSurface), Color(.zodiacPurple))
        case .dominantElement:
            (Color(.pinkIconSurface), Color(.pinkIcon))
        case .weakElement:
            (Color(.purpleIconSurface), Color(.purpleIcon))
        case .synthesis:
            (Color(.surfaceOverlay), Color(.pinkButton))
        }
    }

    private func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text(L10n.Common.continueButton)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.buttonShine),
                            Color(.pinkButton)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.55)
        .background(Color(.surfaceHighlight))
    }
}
