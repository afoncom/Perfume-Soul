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
    private let imageLoader: PerfumeImageLoader
    private let presenter: PerfumeRecommendationsPresenter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        viewModel: PerfumeRecommendationsViewModel,
        presenter: PerfumeRecommendationsPresenter,
        imageLoader: PerfumeImageLoader
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.imageLoader = imageLoader
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                makeBasedOnSection()
                makeRecommendationsSection()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 36)
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
    private func makeBasedOnSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.PerfumeRecommendations.selectedPerfumesTitle)
                .font(.caption.weight(.medium))
                .tracking(0.8)
                .foregroundStyle(Color(.descriptionText))

            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 20))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
            layout {
                ForEach(viewModel.selectedPerfumes) { perfume in
                    makeBasePerfumeItem(perfume: perfume)
                }
            }
        }
    }

    private func makeBasePerfumeItem(perfume: SearchPerfumeItem) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 78)
                .overlay { PerfumeProductImage(perfumeID: perfume.id, loader: imageLoader) }

            Text(perfume.name)
                .font(.caption)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(minHeight: 34, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func makeRecommendationsSection() -> some View {
        LazyVStack(spacing: 24) {
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
        PerfumeBlotterLoadingView(title: L10n.Discover.FindSimilar.loading)
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
        .background(Color(.textPrimary).opacity(0.035))
        .overlay { Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1) }
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
        .multilineTextAlignment(.center)
        .background(Color(.textPrimary).opacity(0.035))
        .overlay { Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1) }
    }

    private func makeRecommendationCard(perfume: PerfumeRecommendation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(width: 72, height: 96)
                .overlay { PerfumeProductImage(perfumeID: perfume.id, loader: imageLoader) }

            VStack(alignment: .leading, spacing: 6) {
                Text(perfume.perfumeName)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)

                Text(perfume.brandName)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))

                makeMatchingNotesSection(notes: viewModel.displayNotes(perfume.matchingNotes))

                VStack(alignment: .leading, spacing: 4) {
                    wearMetric(title: L10n.PerfumeDetails.longevityTitle, score: perfume.longevityScore)
                    wearMetric(title: L10n.PerfumeDetails.sillageTitle, score: perfume.sillageScore)
                }
                .padding(.top, 4)
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

    private func wearMetric(title: String, score: Int?) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                Spacer(minLength: 0)
                Text(viewModel.scoreText(score)).monospacedDigit().fixedSize()
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(viewModel.scoreText(score)).monospacedDigit()
            }
        }
        .font(.footnote)
        .foregroundStyle(Color(.textSecondary))
        .accessibilityElement(children: .combine)
    }
}
