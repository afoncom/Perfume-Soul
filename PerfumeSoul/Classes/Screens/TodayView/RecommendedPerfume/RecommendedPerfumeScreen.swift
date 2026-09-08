//
//  RecommendedPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import SwiftUI

struct RecommendedPerfumeScreen: View {
    @Bindable private var viewModel: RecommendedPerfumeViewModel
    private let presenter: RecommendedPerfumePresenter

    init(
        viewModel: RecommendedPerfumeViewModel,
        presenter: RecommendedPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .empty:
                EmptyView()
            case .loading, .missingProfile, .failed, .content:
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.Today.Recommended.title)
                        .font(.title3)
                        .fontWeight(.medium)
                    Text(L10n.Today.Recommended.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                    makeContent()
                }
            }
        }
        .onAppear {
            Task {
                await presenter.resolve()
            }
        }
    }
}

extension RecommendedPerfumeScreen {
    @ViewBuilder
    private func makeContent() -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 110)
        case .missingProfile:
            makeMessageContent(L10n.Today.Recommended.missingProfile)
        case .failed:
            makeRetryContent()
        case let .content(perfumes):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(perfumes) { perfume in
                        VStack(alignment: .leading, spacing: 6) {
                            Button {
                                presenter.perfumeTapped(perfume)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(.placeholderMedium))
                                        .frame(width: 84, height: 96)
                                    Text(perfume.brandName)
                                        .font(.subheadline)
                                        .foregroundStyle(Color(.textPrimary))
                                        .lineLimit(1)
                                    Text(perfume.perfumeName)
                                        .font(.caption)
                                        .foregroundStyle(Color(.textSecondary))
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                presenter.savePerfume(perfume)
                            } label: {
                                Image(systemName: "heart")
                                    .foregroundStyle(Color(.pinkButton))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(10)
                        .frame(width: 104, alignment: .leading)
                        .background(Color(.surfacePrimary))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
            .padding(.vertical, 4)
        case .empty:
            EmptyView()
        }
    }

    private func makeMessageContent(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color(.textSecondary))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func makeRetryContent() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            makeMessageContent(L10n.Today.Recommended.failed)

            Button {
                Task {
                    await presenter.retry()
                }
            } label: {
                Text(L10n.Today.Recommended.retry)
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
