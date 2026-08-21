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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makeHeaderView()
                makeSectionsView()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 32)
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
        .modifier(TopSafeAreaBackground(isEnabled: presenter.isPresentedInOnboarding))
        .task {
            await presenter.onAppear()
        }
        .safeAreaInset(edge: .bottom) {
            if presenter.isPresentedInOnboarding {
                makeContinueButton()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
        }
    }
}

extension PersonalPerfumeScreen {
    @ViewBuilder
    private func makeSectionsView() -> some View {
        switch viewModel.state {
        case .loading:
            makeLoadingState()
        case let .content(sections):
            makeContentState(sections: sections)
        case .empty:
            makeEmptyState()
        case .missingProfileCalculation:
            makeErrorState(
                title: L10n.PersonalPerfume.Error.MissingProfile.title,
                subtitle: L10n.PersonalPerfume.Error.MissingProfile.subtitle,
                canRetry: false,
                canSkip: presenter.isPresentedInOnboarding
            )
        case .requestFailed:
            makeErrorState(
                title: L10n.PersonalPerfume.Error.RequestFailed.title,
                subtitle: L10n.PersonalPerfume.Error.RequestFailed.subtitle,
                canRetry: true,
                canSkip: presenter.isPresentedInOnboarding
            )
        }
    }

    private func makeHeaderView() -> some View {
        VStack(spacing: 8) {
            if presenter.isPresentedInOnboarding {
                Text(L10n.PersonalPerfume.title)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                    .multilineTextAlignment(.center)
            }

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
                        makePerfumeItem(perfume: perfume)
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

    private func makePerfumeItem(perfume: PersonalPerfumeItem) -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.surfacePrimary))
                .frame(height: 108)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.cardBorder), lineWidth: 1)
                )

            VStack(spacing: 4) {
                Text(perfume.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(perfume.subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(minHeight: 18, alignment: .top)

                Spacer(minLength: 0)

                makeMatchBadge(matchPercentage: perfume.matchPercentage)
            }
            .frame(minHeight: 80, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func makeMatchBadge(matchPercentage: Int) -> some View {
        Text(L10n.PersonalPerfume.matchFormat(matchPercentage))
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .foregroundStyle(Color(.pinkButton))
            .background(Color(.pinkButton).opacity(0.12))
            .clipShape(Capsule())
    }

    private func makeContentState(sections: [PersonalPerfumeSection]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                makePerfumeSection(section: section)
            }
        }
    }

    private func makeLoadingState() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }

    private func makeErrorState(
        title: String,
        subtitle: String,
        canRetry: Bool,
        canSkip: Bool
    ) -> some View {
        makeMessageState(
            title: title,
            subtitle: subtitle,
            canRetry: canRetry,
            canSkip: canSkip
        )
    }

    private func makeEmptyState() -> some View {
        makeMessageState(
            title: L10n.PersonalPerfume.Empty.title,
            subtitle: L10n.PersonalPerfume.Empty.subtitle,
            canRetry: false,
            canSkip: false
        )
    }

    private func makeMessageState(
        title: String,
        subtitle: String,
        canRetry: Bool,
        canSkip: Bool
    ) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)

            if canRetry {
                Button {
                    Task {
                        await presenter.retryButtonTapped()
                    }
                } label: {
                    Text(L10n.PersonalPerfume.retryButton)
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
                    Text(L10n.PersonalPerfume.skipButton)
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
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
                .background(Color(.pinkButton))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.55)
        .background(Color(.surfaceHighlight))
    }
}
