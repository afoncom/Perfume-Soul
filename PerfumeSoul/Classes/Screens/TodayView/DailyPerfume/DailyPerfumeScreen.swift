//
//  DailyPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DailyPerfumeScreen: View {
    @Bindable private var viewModel: DailyPerfumeViewModel
    private let presenter: DailyPerfumePresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        viewModel: DailyPerfumeViewModel,
        presenter: DailyPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.Today.Aroma.title)
                .font(.title2.weight(.semibold))
                .tracking(-0.5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            makeContent()
        }
        .foregroundStyle(Color(.textPrimary))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: viewModel.state)
        .task {
            await presenter.resolve()
        }
    }
}

extension DailyPerfumeScreen {
    @ViewBuilder
    private func makeContent() -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Color(.textPrimary))
                .frame(maxWidth: .infinity, minHeight: 300)
                .background(Color(.textPrimary).opacity(0.035))
        case .missingProfile:
            makeMessageContent(L10n.Today.Aroma.missingProfile)
        case let .content(perfume, reaction):
            makePerfumeContent(perfume: perfume, reaction: reaction)
        case .exhausted:
            makeMessageContent(L10n.Today.Aroma.exhausted)
        case .failed:
            VStack(alignment: .leading, spacing: 16) {
                makeMessageContent(L10n.Today.Aroma.failed)
                PerfumePrimaryButton(title: L10n.Today.Aroma.retry) {
                    Task { await presenter.retry() }
                }
            }
        }
    }

    @ViewBuilder
    private func makePerfumeContent(
        perfume: DailyPerfumeSummary,
        reaction: DailyPerfumeReaction
    ) -> some View {
        switch reaction {
        case .pending:
            makePendingPerfumeContent(perfume)
        case .saved, .dismissed:
            makeResolvedPerfumeContent(perfume: perfume, reaction: reaction)
        }
    }

    private func makePendingPerfumeContent(_ perfume: DailyPerfumeSummary) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                presenter.perfumeTapped(perfume)
            } label: {
                VStack(alignment: .leading, spacing: 20) {
                    // Reserved for the actual fragrance photograph.
                    Rectangle()
                        .fill(Color(.textPrimary).opacity(0.035))
                        .aspectRatio(1.2, contentMode: .fit)
                        .overlay {
                            Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
                        }
                        .accessibilityHidden(true)

                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(perfume.brandName.uppercased())
                                .font(.caption.weight(.medium))
                                .tracking(1)
                                .foregroundStyle(Color(.descriptionText))

                            Text(perfume.perfumeName)
                                .font(.title.weight(.medium))
                                .tracking(-0.6)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.up.right")
                            .font(.title3)
                            .padding(.top, 4)
                            .accessibilityHidden(true)
                    }
                }
                .multilineTextAlignment(.leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.PersonalPerfume.openDetailsHint)

            makeReactionButtons()
        }
    }

    private func makeReactionButtons() -> some View {
        VStack(spacing: 12) {
            PerfumePrimaryButton(title: L10n.Today.Aroma.primaryAction) {
                presenter.saveCurrentPerfume()
            }

            Button {
                presenter.dismissCurrentPerfume()
            } label: {
                Text(L10n.Today.Aroma.secondaryAction)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 17)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .overlay {
                        Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func makeResolvedPerfumeContent(
        perfume: DailyPerfumeSummary,
        reaction: DailyPerfumeReaction
    ) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 0) {
                if reaction == .dismissed {
                    makeEditorialImage()
                }

                // Reserved for the actual fragrance photograph.
                Rectangle()
                    .fill(Color(.textPrimary).opacity(0.035))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                if reaction == .saved {
                    makeEditorialImage()
                }
            }
            .aspectRatio(1.65, contentMode: .fit)
            .clipped()

            Button {
                presenter.perfumeTapped(perfume)
            } label: {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(perfume.brandName.uppercased())
                            .font(.caption.weight(.medium))
                            .tracking(1)
                            .foregroundStyle(Color(.descriptionText))

                        Text(perfume.perfumeName)
                            .font(.title.weight(.medium))
                            .tracking(-0.6)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "arrow.up.right")
                        .font(.title3)
                        .padding(.top, 4)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.PersonalPerfume.openDetailsHint)

            Text(reaction == .saved ? L10n.Today.Aroma.savedMessage : L10n.Today.Aroma.dismissedMessage)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color(.inputBorder))
                        .frame(height: 1)
                }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func makeEditorialImage() -> some View {
        Image(.perfumeStudioPhoto)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityHidden(true)
    }

    private func makeMessageContent(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(Color(.descriptionText))
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.textPrimary).opacity(0.035))
    }
}
