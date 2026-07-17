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
        let bottomPadding: CGFloat = presenter.shouldShowContinueButton ? 140 : 32

        ZStack {
            if let profileDescription = viewModel.profileDescription {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 26) {
                        makeHeaderView(profileDescription: profileDescription)
                        makeInsightCards(profileDescription: profileDescription)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, bottomPadding)
                }
            } else if viewModel.profile != nil {
                makeUnavailableState()
                    .padding(.horizontal, 24)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
    
    private func makeUnavailableState() -> some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(.pinkIcon))

            Text(L10n.ProfileDescription.unavailableTitle)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.titleText))

            Text(L10n.ProfileDescription.unavailableMessage)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
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
        .background(Color(.surfaceHighlight))
    }
}
