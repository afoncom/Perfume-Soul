//
//  PerfumeDetailsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import SwiftUI

struct PerfumeDetailsScreen: View {
    @Bindable private var viewModel: PerfumeDetailsViewModel
    @State private var isStoryExpanded = false
    private let presenter: PerfumeDetailsPresenter

    init(
        viewModel: PerfumeDetailsViewModel,
        presenter: PerfumeDetailsPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content
                .padding(.horizontal, 16)
                .padding(.top, 16)
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

extension PerfumeDetailsScreen {
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            makeLoadingState()
        } else if let errorMessage = viewModel.errorMessage {
            makeErrorState(message: errorMessage)
        } else if let perfumeDetails = viewModel.perfumeDetails {
            VStack(spacing: 18) {
                makePerfumeHeader(perfumeDetails: perfumeDetails)
                if let recommendationReason = PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails) {
                    makeRecommendationSection(recommendationReason: recommendationReason)
                }
                if let fullStory = PerfumeDetailsTextFormatter.fullStory(for: perfumeDetails) {
                    makeStorySection(fullStory: fullStory)
                }
                makeNotesSection(perfumeDetails: perfumeDetails)
                makeWearSection(perfumeDetails: perfumeDetails)
            }
        }
    }

    private func makeLoadingState() -> some View {
        VStack(spacing: 14) {
            ProgressView()
            Text(L10n.PerfumeDetails.loadingMessage)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
        }
        .frame(maxWidth: .infinity, minHeight: 360)
    }

    private func makeErrorState(message: String) -> some View {
        VStack(spacing: 14) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await presenter.retryTapped()
                }
            } label: {
                Text(L10n.PerfumeDetails.retryButton)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textPrimary))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.surfacePrimary))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(.cardBorder), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 360)
        .padding(.horizontal, 24)
    }

    private func makePerfumeHeader(perfumeDetails: PerfumeDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                makePerfumeImage(perfumeDetails: perfumeDetails)

                VStack(alignment: .leading, spacing: 8) {
                    Text(perfumeDetails.brand)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.textSecondary))

                    Text(perfumeDetails.name)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color(.textPrimary))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(PerfumeDetailsTextFormatter.shortDescription(for: perfumeDetails))
                        .font(.footnote)
                        .foregroundStyle(Color(.descriptionText))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            makeQuickFacts(perfumeDetails: perfumeDetails)

            if !perfumeDetails.accords.isEmpty {
                makeAccordsPreview(accords: perfumeDetails.accords)
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    private func makePerfumeImage(perfumeDetails: PerfumeDetails) -> some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(.placeholderSoft),
                        Color(.placeholderMedium)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 112, height: 148)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color(.pinkButton))
                        .accessibilityHidden(true)

                    Text(perfumeInitials(perfumeDetails))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(.textPrimary))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(.cardBorder), lineWidth: 1)
            )
    }

    private func makeQuickFacts(perfumeDetails: PerfumeDetails) -> some View {
        let facts = quickFacts(for: perfumeDetails)

        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 132), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(facts, id: \.title) { fact in
                makeFactChip(title: fact.title, value: fact.value)
            }
        }
    }

    private func makeFactChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color(.textSecondary))
                .lineLimit(1)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func makeAccordsPreview(accords: [PerfumeAccord]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.PerfumeDetails.mainAccordsTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(.textPrimary))

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 86), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(accords.prefix(5), id: \.name) { accord in
                    makeCompactChip(
                        text: PerfumeDetailsTextFormatter.localizedAccord(accord.name).localizedCapitalized,
                        accentColor: Color(.zodiacPurple)
                    )
                }
            }
        }
    }

    private func makeRecommendationSection(recommendationReason: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.title3)
                .foregroundStyle(Color(.pinkButton))
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.PerfumeDetails.recommendationReasonTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.textPrimary))

                Text(recommendationReason)
                    .font(.footnote)
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(.purpleTable))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.tableBorder), lineWidth: 1)
        )
    }

    private func makeStorySection(fullStory: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isStoryExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Text(L10n.PerfumeDetails.historyTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.textPrimary))

                    Spacer()

                    Text(storyButtonTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.pinkButton))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Image(systemName: isStoryExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(.pinkButton))
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.PerfumeDetails.historyTitle)
            .accessibilityValue(storyButtonTitle)
            .accessibilityAddTraits(isStoryExpanded ? .isSelected : [])

            if isStoryExpanded {
                Text(fullStory)
                    .font(.footnote)
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
    }

    private func perfumeInitials(_ perfumeDetails: PerfumeDetails) -> String {
        let words = [perfumeDetails.brand, perfumeDetails.name]
            .compactMap { $0.split(separator: " ").first?.first }

        return words.map(String.init).joined().uppercased()
    }

    private func quickFacts(for perfumeDetails: PerfumeDetails) -> [(title: String, value: String)] {
        let facts: [(String, String?)] = [
            (L10n.PerfumeDetails.releaseYearTitle, perfumeDetails.releaseYear.map(String.init)),
            (L10n.PerfumeDetails.perfumerTitle, perfumeDetails.perfumer),
            (L10n.PerfumeDetails.concentrationTitle, PerfumeDetailsTextFormatter.localizedConcentration(perfumeDetails.concentration)),
            (L10n.PerfumeDetails.familyTitle, PerfumeDetailsTextFormatter.localizedProfilePhrase(perfumeDetails.fragranceFamily)),
            (L10n.PerfumeDetails.seasonTitle, PerfumeDetailsTextFormatter.localizedProfilePhrase(perfumeDetails.seasonProfile)),
            (L10n.PerfumeDetails.moodTitle, PerfumeDetailsTextFormatter.localizedProfilePhrase(perfumeDetails.moodProfile))
        ]

        return facts
            .compactMap { fact in
                guard let value = fact.1,
                    !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return nil
                }

                return (fact.0, value)
            }
    }

    private var storyButtonTitle: String {
        isStoryExpanded
            ? L10n.PerfumeDetails.hideDescriptionButton
            : L10n.PerfumeDetails.openDescriptionButton
    }

    private func makeCompactChip(
        text: String,
        accentColor: Color
    ) -> some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(accentColor)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(accentColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private func makeNotesSection(perfumeDetails: PerfumeDetails) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.PerfumeDetails.notesSectionTitle)

            makeNotesCard(
                topAccentColor: Color(.pinkButton),
                topNotes: perfumeDetails.topNotes,
                middleNotes: perfumeDetails.middleNotes,
                baseNotes: perfumeDetails.baseNotes
            )
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    private func makeNotesCard(
        topAccentColor: Color,
        topNotes: [String],
        middleNotes: [String],
        baseNotes: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeNotesGroup(
                title: L10n.PerfumeDetails.topNotesTitle,
                notes: topNotes,
                accentColor: topAccentColor
            )

            makeNotesGroup(
                title: L10n.PerfumeDetails.middleNotesTitle,
                notes: middleNotes,
                accentColor: Color(.zodiacPurple)
            )

            makeNotesGroup(
                title: L10n.PerfumeDetails.baseNotesTitle,
                notes: baseNotes,
                accentColor: Color(.zodiacOrange)
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func makeNotesGroup(
        title: String,
        notes: [String],
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.textPrimary))

            if notes.isEmpty {
                Text(L10n.PerfumeDetails.emptyNotesPlaceholder)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 110), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(notes, id: \.self) { note in
                        makeCompactChip(text: note, accentColor: accentColor)
                    }
                }
            }
        }
    }

    private func makeWearSection(perfumeDetails: PerfumeDetails) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.PerfumeDetails.onSkinSectionTitle)

            makeWearCard(
                accentColor: Color(.pinkButton),
                metrics: [
                    (L10n.PerfumeDetails.longevityTitle, scoreText(perfumeDetails.longevityScore)),
                    (L10n.PerfumeDetails.sillageTitle, scoreText(perfumeDetails.sillageScore))
                ]
            )
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    private func makeWearCard(
        accentColor: Color,
        metrics: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 10) {
                ForEach(metrics, id: \.0) { metric in
                    makeWearRow(
                        title: metric.0,
                        score: metric.1,
                        accentColor: accentColor
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func makeWearRow(
        title: String,
        score: String,
        accentColor: Color
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color(.textPrimary))

            Spacer(minLength: 8)

            Text(score)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(accentColor.opacity(0.14))
                .clipShape(Capsule())
        }
        .accessibilityElement(children: .combine)
    }

    private func scoreText(_ score: Int?) -> String {
        guard let score else {
            return "--"
        }

        return "\(score)/10"
    }

    private func makeSectionTitle(_ title: String) -> some View {
        HStack {
            Spacer()

            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(Color(.textPrimary))

            Spacer()
        }
    }
}
