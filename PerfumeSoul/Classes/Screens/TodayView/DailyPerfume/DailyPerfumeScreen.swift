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

    init(
        viewModel: DailyPerfumeViewModel,
        presenter: DailyPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Aroma.title)
                .font(.title3)
                .fontWeight(.medium)

            makeContent()
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(.cardShadow), radius: 10, x: 0, y: 4)
    }
}

private extension DailyPerfumeScreen {
    @ViewBuilder
    func makeContent() -> some View {
        switch viewModel.state {
        case .loading:
            makeLoadingContent()
        case .missingProfile:
            makeMessageContent(L10n.Today.Aroma.missingProfile)
        case let .content(perfume, reaction):
            makePerfumeContent(perfume: perfume, reaction: reaction)
        case .exhausted:
            makeMessageContent(L10n.Today.Aroma.exhausted)
        case .failed:
            makeRetryContent()
        }
    }

    func makeLoadingContent() -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(.placeholderMedium))
                    .frame(width: 124, height: 22)

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(.placeholderSoft))
                    .frame(width: 100, height: 16)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(width: 82, height: 112)
        }
        .redacted(reason: .placeholder)
    }

    func makePerfumeContent(
        perfume: DailyPerfumeSummary,
        reaction: DailyPerfumeReaction
    ) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    presenter.perfumeTapped(perfume)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(perfume.brandName)
                            .font(.subheadline)
                            .foregroundStyle(Color(.textSecondary))

                        Text(perfume.perfumeName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(.textPrimary))
                    }
                }
                .buttonStyle(.plain)

                makeReactionContent(reaction)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                presenter.perfumeTapped(perfume)
            } label: {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.placeholderMedium))
                    .frame(width: 82, height: 112)
                    .overlay {
                        Image(systemName: "bottle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(.textSecondary))
                    }
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    func makeReactionContent(_ reaction: DailyPerfumeReaction) -> some View {
        switch reaction {
        case .pending:
            HStack(spacing: 6) {
                Button {
                    presenter.saveCurrentPerfume()
                } label: {
                    Text(L10n.Today.Aroma.primaryAction)
                        .font(.caption)
                        .foregroundStyle(Color(.textOnAccent))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(.pinkButton))
                        .clipShape(Capsule())
                }

                Button {
                    presenter.dismissCurrentPerfume()
                } label: {
                    Text(L10n.Today.Aroma.secondaryAction)
                        .font(.caption)
                        .foregroundStyle(Color(.textSecondary))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(.secondaryButtonBackground))
                        .overlay {
                            Capsule()
                                .stroke(Color(.secondaryButtonBorder), lineWidth: 1)
                        }
                }
            }
        case .saved:
            makeMessageContent(L10n.Today.Aroma.savedMessage)
        case .dismissed:
            makeMessageContent(L10n.Today.Aroma.dismissedMessage)
        }
    }

    func makeMessageContent(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color(.textSecondary))
            .fixedSize(horizontal: false, vertical: true)
    }

    func makeRetryContent() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            makeMessageContent(L10n.Today.Aroma.failed)

            Button {
                Task {
                    await presenter.retry()
                }
            } label: {
                Text(L10n.Today.Aroma.retry)
                    .font(.caption)
                    .foregroundStyle(Color(.textSecondary))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.secondaryButtonBackground))
                    .overlay {
                        Capsule()
                            .stroke(Color(.secondaryButtonBorder), lineWidth: 1)
                    }
            }
        }
    }
}
