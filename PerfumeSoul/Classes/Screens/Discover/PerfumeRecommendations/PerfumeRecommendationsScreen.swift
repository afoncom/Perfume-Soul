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
                makeBasedOnSection()
                if shouldShowHintCard {
                    makeHintCard()
                }
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
    private var shouldShowHintCard: Bool {
        !viewModel.isLoading &&
        viewModel.errorMessage == nil &&
        !viewModel.perfumeRecommendations.isEmpty
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
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(minHeight: 34, alignment: .top)
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

                makeMatchingNotesSection(notes: perfume.matchingNotes)

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
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(.textSecondary))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

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

    @ViewBuilder
    private func makeMatchingNotesSection(notes: [String]) -> some View {
        if !notes.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.PerfumeRecommendations.matchingNotesTitle)
                    .font(.caption)
                    .foregroundStyle(Color(.textSecondary))

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 72), spacing: 6)],
                    alignment: .leading,
                    spacing: 6
                ) {
                    ForEach(Array(notes.prefix(3)), id: \.self) { note in
                        makeMatchingNoteChip(note: note)
                    }

                    if notes.count > 3 {
                        makeMatchingNoteChip(note: "+\(notes.count - 3)")
                    }
                }
            }
        }
    }

    private func makeMatchingNoteChip(note: String) -> some View {
        Text(note)
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color(.zodiacPurple))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(Color(.zodiacPurple).opacity(0.1))
            .clipShape(Capsule())
    }

    private func scoreText(_ score: Int?) -> String {
        score.map(String.init) ?? L10n.PerfumeDetails.emptyNotesPlaceholder
    }
}
