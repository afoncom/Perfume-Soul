//
//  PersonalPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct PersonalPerfumeScreen: View {
    @Bindable private var viewModel: PersonalPerfumeViewModel
    private let presenter: PersonalPerfumePresenter

    init(
        viewModel: PersonalPerfumeViewModel,
        presenter: PersonalPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        let bottomPadding: CGFloat = presenter.shouldShowContinueButton ? 120 : 32

        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makeHeaderView()
                makeSectionsView()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, bottomPadding)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.backgroundPrimary)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .task {
            presenter.onAppear()
        }
        .safeAreaInset(edge: .bottom) {
            if presenter.shouldShowContinueButton {
                makeContinueButton()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
        }
    }
}

extension PersonalPerfumeScreen {
    private func makeSectionsView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(viewModel.sections.enumerated()), id: \.offset) { _, section in
                makePerfumeSection(section: section)
            }
        }
    }

    private func makeHeaderView() -> some View {
        VStack(spacing: 8) {
            Text(L10n.PersonalPerfume.title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))
                .multilineTextAlignment(.center)

            Text(L10n.PersonalPerfume.subtitle)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private func makePerfumeSection(section: PersonalPerfumeSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(section.title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(section.perfumes.enumerated()), id: \.offset) { _, perfume in
                        makePerfumeItem(name: perfume.name, subtitle: perfume.subtitle)
                    }
                }

                Text(section.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color(.purpleTable))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(.tableBorder), lineWidth: 1)
            )
        }
    }

    private func makePerfumeItem(name: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.surfacePrimary))
                .frame(height: 108)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.cardBorder), lineWidth: 1)
                )

            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
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
