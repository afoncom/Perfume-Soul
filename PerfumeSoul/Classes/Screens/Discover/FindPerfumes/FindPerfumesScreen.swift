//
//  FindPerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct FindPerfumesScreen: View {
    @Bindable private var viewModel: FindPerfumesViewModel
    private let presenter: FindPerfumesPresenter
    
    init(
        viewModel: FindPerfumesViewModel,
        presenter: FindPerfumesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 22) {
                makeHeaderView()
                makePerfumeFieldsSection()
                makeHintCard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 28)
            .padding(.bottom, 120)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            makeFindButton()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension FindPerfumesScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 10) {
            Text(L10n.Discover.FindSimilar.title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))
                .multilineTextAlignment(.center)
            
            Text(L10n.Discover.FindSimilar.headerSubtitle)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
    
    func makePerfumeFieldsSection() -> some View {
        VStack(spacing: 14) {
            makePerfumeField(
                title: L10n.Discover.FindSimilar.firstPerfumeTitle,
                subtitle: L10n.Discover.FindSimilar.firstPerfumeSubtitle,
                iconColor: Color(.pinkButton),
                trailingSymbol: "magnifyingglass"
            )
            
            makePerfumeField(
                title: L10n.Discover.FindSimilar.secondPerfumeTitle,
                subtitle: L10n.Discover.FindSimilar.optionalSubtitle,
                iconColor: Color(.textSecondary),
                trailingSymbol: "plus"
            )
            
            makePerfumeField(
                title: L10n.Discover.FindSimilar.thirdPerfumeTitle,
                subtitle: L10n.Discover.FindSimilar.optionalSubtitle,
                iconColor: Color(.textSecondary),
                trailingSymbol: "plus"
            )
        }
    }
    
    func makePerfumeField(
        title: String,
        subtitle: String,
        iconColor: Color,
        trailingSymbol: String
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.surfaceOverlay))
                    .frame(width: 46, height: 46)
                
                Image(systemName: "bag")
                    .font(.headline)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
            }
            
            Spacer()
            
            Image(systemName: trailingSymbol)
                .font(.title3)
                .foregroundStyle(Color(.textSecondary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeHintCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color(.zodiacPurple))
            
            Text(L10n.Discover.FindSimilar.hint)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.purpleTable))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.tableBorder), lineWidth: 1)
        )
    }
    
    func makeFindButton() -> some View {
        Button {
            presenter.findSimilarPerfumesButtonTapped()
        } label: {
            Text(L10n.Discover.FindSimilar.button)
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
