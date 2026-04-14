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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 26) {
                makeHeaderView()
                makeEmptyHeroSection()
                makeInsightCards()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 140)
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            makeContinueButton()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
    }
}

private extension ProfileDescriptionScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 10) {
            Text("Anna, you are")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.82))
                .multilineTextAlignment(.center)
            
            Text("Deep, Intuitive, Magnetic\nPersonality")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.62))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 8)
    }
    
    func makeEmptyHeroSection() -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 220)
    }
    
    func makeInsightCards() -> some View {
        VStack(spacing: 14) {
            makeInsightCard(
                symbol: "drop.fill",
                iconTint: Color.purpleIcon,
                title: "Water dominant",
                description: "You are deeply intuitive and empathetic."
            )
            
            makeInsightCard(
                symbol: "heart.fill",
                iconTint: Color.pinkIcon,
                title: "Strong emotional perception",
                description: "You can easily sense the moods and feelings of others."
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeInsightCard(
        symbol: String,
        iconTint: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.22))
                    .frame(width: 42, height: 42)
                
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconTint)
            }
            .frame(width: 42, height: 42, alignment: .top)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.8))
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 8)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color(red: 0.74, green: 0.63, blue: 0.84).opacity(0.12), radius: 18, x: 0, y: 10)
    }
    
    func makeContinueButton() -> some View {
        Button(action: { }) {
            Text("Continue")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            .pinkButton.opacity(0.82)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .background(Color.white.opacity(0.08))
    }
}
