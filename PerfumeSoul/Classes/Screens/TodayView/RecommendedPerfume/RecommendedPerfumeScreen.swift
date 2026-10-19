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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                VStack(alignment: .leading, spacing: 24) {
                    makeHeader()
                        .padding(.horizontal, 24)
                    makeContent()
                }
                .foregroundStyle(Color(.textPrimary))
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
    private func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color(.inputBorder))
                .frame(height: 1)
                .padding(.bottom, 12)
                .accessibilityHidden(true)

            Text(L10n.Today.Recommended.title)
                .font(.title2.weight(.semibold))
                .tracking(-0.5)
                .accessibilityAddTraits(.isHeader)

            Text(L10n.Today.Recommended.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(3)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func makeContent() -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Color(.textPrimary))
                .frame(maxWidth: .infinity, minHeight: 220)
                .background(Color(.textPrimary).opacity(0.035))
                .padding(.horizontal, 24)
        case .missingProfile:
            makeMessageContent(L10n.Today.Recommended.missingProfile)
                .padding(.horizontal, 24)
        case .failed:
            VStack(alignment: .leading, spacing: 16) {
                makeMessageContent(L10n.Today.Recommended.failed)
                PerfumePrimaryButton(title: L10n.Today.Recommended.retry) {
                    Task { await presenter.retry() }
                }
            }
            .padding(.horizontal, 24)
        case let .content(perfumes):
            if dynamicTypeSize.isAccessibilitySize {
                LazyVStack(spacing: 24) {
                    ForEach(Array(perfumes.enumerated()), id: \.element.id) { index, perfume in
                        makeCard(perfume: perfume, index: index)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                makeInteractiveRail(perfumes)
            }
        case .empty:
            EmptyView()
        }
    }

    private func makeInteractiveRail(_ perfumes: [DailyPerfumeSummary]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 14) {
                ForEach(Array(perfumes.enumerated()), id: \.element.id) { index, perfume in
                    makeCard(perfume: perfume, index: index)
                        .containerRelativeFrame(.horizontal) { width, _ in
                            width * 0.82
                        }
                        .scrollTransition(.interactive, axis: .horizontal) { [reduceMotion] content, phase in
                            content
                                .opacity(reduceMotion || phase.isIdentity ? 1 : 0.78)
                                .scaleEffect(reduceMotion || phase.isIdentity ? 1 : 0.97)
                                .offset(y: reduceMotion || phase.isIdentity ? 0 : 8)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 24, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
    }

    private func makeCard(perfume: DailyPerfumeSummary, index: Int) -> some View {
        RecommendedPerfumeCompactCard(
            perfume: perfume,
            index: index,
            onSelect: { presenter.perfumeTapped(perfume) },
            onSave: { presenter.savePerfume(perfume) }
        )
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

private struct RecommendedPerfumeCompactCard: View {
    let perfume: DailyPerfumeSummary
    let index: Int
    let onSelect: () -> Void
    let onSave: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onSelect) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 16) {
                        makeImagePlaceholder(isWide: true)
                        details
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        if index.isMultiple(of: 2) {
                            makeImagePlaceholder(isWide: false)
                            details
                        } else {
                            details
                            makeImagePlaceholder(isWide: false)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.PersonalPerfume.openDetailsHint)

            Button(action: onSave) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(L10n.Today.Recommended.saveAction)
                        .font(.subheadline.weight(.medium))
                    Spacer(minLength: 0)
                    Image(systemName: "plus")
                        .font(.subheadline)
                        .accessibilityHidden(true)
                }
                .padding(.top, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color(.textPrimary))
        .padding(16)
        .background(Color(.textPrimary).opacity(0.035))
        .overlay {
            Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: "%02d", index + 1))
                .font(.caption.monospacedDigit())
                .foregroundStyle(Color(.descriptionText))
                .accessibilityHidden(true)

            Spacer(minLength: 8)

            Text(perfume.brandName.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.8)
                .foregroundStyle(Color(.descriptionText))
                .lineLimit(1)

            Text(perfume.perfumeName)
                .font(.headline)
                .tracking(-0.2)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)

            Image(systemName: "arrow.up.right")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityHidden(true)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 120 : 132, alignment: .leading)
    }

    private func makeImagePlaceholder(isWide: Bool) -> some View {
        // Reserved for the actual fragrance photograph.
        Rectangle()
            .fill(Color(.backgroundPrimary))
            .frame(
                maxWidth: isWide ? .infinity : 104,
                minHeight: isWide ? 160 : 132,
                maxHeight: isWide ? 160 : 132
            )
            .overlay {
                Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}
