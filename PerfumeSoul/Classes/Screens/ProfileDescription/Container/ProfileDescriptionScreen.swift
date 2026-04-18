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
        ZStack {
            if let profile = viewModel.profile {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 26) {
                        makeHeaderView(profile: profile)
                        makeInsightCards()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 140)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            makeContinueButton()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
        .task {
            await presenter.onAppear()
        }
    }
}

private extension ProfileDescriptionScreen {
    func makeHeaderView(profile: Profile) -> some View {
        VStack(spacing: 10) {
            Text("\(profile.name), you are")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(.titleText)
                .multilineTextAlignment(.center)
            
            Text("Deep, Intuitive, Magnetic\nPersonality")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(.bodyText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 8)
    }
    
    func makeInsightCards() -> some View {
        VStack(spacing: 14) {
            makeInsightCard(
                symbol: "drop.fill",
                iconBackground: .purpleIconSurface,
                iconTint: Color.purpleIcon,
                title: "Water dominant",
                description: "You are deeply intuitive and empathetic."
            )
            
            makeInsightCard(
                symbol: "heart.fill",
                iconBackground: .pinkIconSurface,
                iconTint: Color.pinkIcon,
                title: "Strong emotional perception",
                description: "You can easily sense the moods and feelings of others."
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeInsightCard(
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
                    .foregroundStyle(.titleText)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.descriptionText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 8)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(.surfaceOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.glassBorder, lineWidth: 1)
        )
        .shadow(color: .insightCardShadow, radius: 18, x: 0, y: 10)
    }
    
    func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text("Continue")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.textOnAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [
                            .buttonShine,
                            .pinkButton
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .background(.surfaceHighlight)
    }
}
