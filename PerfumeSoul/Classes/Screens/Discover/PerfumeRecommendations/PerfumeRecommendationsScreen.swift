//
//  PerfumeRecommendationsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct PerfumeRecommendationsScreen: View {
    @Bindable private var viewModel: PerfumeRecommendationsViewModel
    private let presenter: PerfumeRecommendationsPresenter

    init(
        viewModel: PerfumeRecommendationsViewModel,
        presenter: PerfumeRecommendationsPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makeHeaderView()
                makeBasedOnSection()
                makeHintCard()
                makeRecommendationsSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .task {
            await presenter.onAppear()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension PerfumeRecommendationsScreen {
    private func makeHeaderView() -> some View {
        Text(L10n.Screen.perfumeRecommendations)
            .font(.system(size: 30, weight: .medium, design: .rounded))
            .foregroundStyle(Color(.titleText))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
    }

    private func makeBasedOnSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.PerfumeRecommendations.selectedPerfumesTitle)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))

            HStack(spacing: 12) {
                ForEach(viewModel.selectedPerfumes) { perfume in
                    makeBasePerfumeItem(title: perfume.name)
                }
            }
        }
    }

    private func makeBasePerfumeItem(title: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 78)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
    }

    private func makeHintCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color(.zodiacPurple))

            Text(L10n.PerfumeRecommendations.hint)
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

    @ViewBuilder
    private func makeRecommendationsSection() -> some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                makeLoadingState()
            } else if let errorMessage = viewModel.errorMessage {
                makeErrorState(message: errorMessage)
            } else if viewModel.perfumeRecommendations.isEmpty {
                makeEmptyStateView()
            } else {
                ForEach(viewModel.perfumeRecommendations, id: \.id) { perfume in
                    Button {
                        presenter.recommendationTapped(perfume)
                    } label: {
                        makeRecommendationCard(perfume: perfume)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func makeLoadingState() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }

    private func makeErrorState(message: String) -> some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)

            Text(L10n.PerfumeRecommendations.Empty.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
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

    private func makeEmptyStateView() -> some View {
        VStack(spacing: 8) {
            Text(L10n.PerfumeRecommendations.Empty.title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))

            Text(L10n.PerfumeRecommendations.Empty.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
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

    private func makeRecommendationCard(perfume: PerfumeRecommendation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(width: 72, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                Text(perfume.perfumeName)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)

                Text(perfume.brandName)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))

                Text(
                    L10n.PerfumeRecommendations.matchingNotesFormat(
                        perfume.matchingNotes.joined(separator: ", ")
                    )
                )
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)

                Text(
                    L10n.PerfumeRecommendations.wearFormat(
                        scoreText(perfume.longevityScore),
                        scoreText(perfume.sillageScore)
                    )
                )
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 12) {
                Text("\(perfume.matchPercentage)%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))

                Text(L10n.PerfumeRecommendations.matchLabel)
                    .font(.caption)
                    .foregroundStyle(Color(.textSecondary))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
            }
            .frame(width: 64)
        }
        .padding(12)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    private func scoreText(_ score: Int?) -> String {
        score.map(String.init) ?? L10n.PerfumeDetails.emptyNotesPlaceholder
    }
}
