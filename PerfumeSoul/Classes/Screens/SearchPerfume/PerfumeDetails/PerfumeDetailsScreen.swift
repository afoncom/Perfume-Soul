//
//  PerfumeDetailsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import SwiftUI

struct PerfumeDetailsScreen: View {
    @Bindable private var viewModel: PerfumeDetailsViewModel
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
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 220)

            VStack(spacing: 4) {
                Text(perfumeDetails.brand)
                    .font(.headline)
                    .foregroundStyle(Color(.textSecondary))

                Text(perfumeDetails.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))
                    .multilineTextAlignment(.center)
            }
            .multilineTextAlignment(.center)
        }
    }

    private func makeNotesSection(perfumeDetails: PerfumeDetails) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle(L10n.PerfumeDetails.notesSectionTitle)

            makeNotesCard(
                accentColor: Color(.pinkButton),
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
        accentColor: Color,
        topNotes: [String],
        middleNotes: [String],
        baseNotes: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(accentColor.opacity(0.22))
                .frame(width: 48, height: 6)

            makeNotesGroup(
                title: L10n.PerfumeDetails.topNotesTitle,
                notes: topNotes,
                accentColor: accentColor
            )

            makeNotesGroup(
                title: L10n.PerfumeDetails.middleNotesTitle,
                notes: middleNotes,
                accentColor: accentColor
            )

            makeNotesGroup(
                title: L10n.PerfumeDetails.baseNotesTitle,
                notes: baseNotes,
                accentColor: accentColor
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

            VStack(alignment: .leading, spacing: 8) {
                if notes.isEmpty {
                    Text(L10n.PerfumeDetails.emptyNotesPlaceholder)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                } else {
                    ForEach(notes, id: \.self) { note in
                        makeNoteRow(
                            note: note,
                            accentColor: accentColor
                        )
                    }
                }
            }
        }
    }

    private func makeNoteRow(
        note: String,
        accentColor: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(accentColor.opacity(0.75))
                .frame(width: 8, height: 8)
                .padding(.top, 4)

            Text(note)
                .font(.footnote)
                .foregroundStyle(Color(.textPrimary))
                .fixedSize(horizontal: false, vertical: true)
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
        HStack(alignment: .center, spacing: 10) {
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
    }

    private func scoreText(_ score: Int?) -> String {
        guard let score else { return "--" }
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
