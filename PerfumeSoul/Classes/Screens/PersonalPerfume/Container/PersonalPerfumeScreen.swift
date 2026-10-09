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
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 32

    init(viewModel: PersonalPerfumeViewModel, presenter: PersonalPerfumePresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                makeHeader()
                    .padding(.horizontal, 24)

                makeSections()
            }
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.backgroundPrimary))
        .preferredColorScheme(.light)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if presenter.shouldShowContinueButton {
                PerfumePrimaryButton(title: L10n.Common.continueButton) {
                    presenter.continueButtonTapped()
                }
                .disabled(!viewModel.canContinue)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.backgroundPrimary).ignoresSafeArea(edges: .bottom))
            }
        }
        .task {
            await presenter.onAppear()
        }
    }
}

extension PersonalPerfumeScreen {
    private func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 28) {
            PerfumeFlowHeader(section: L10n.PersonalPerfume.collectionSection, step: nil)

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.PersonalPerfume.title)
                    .font(.system(size: headingSize, weight: .semibold))
                    .tracking(-0.8)
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(L10n.PersonalPerfume.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func makeSections() -> some View {
        switch viewModel.state {
        case .loading:
            VStack(spacing: 16) {
                ProgressView()
                    .tint(Color(.textPrimary))
                Text(L10n.PersonalPerfume.loading)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
            }
            .frame(maxWidth: .infinity, minHeight: 240)
            .padding(.horizontal, 24)
        case let .content(sections):
            VStack(spacing: 36) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                    PersonalPerfumeCollectionSection(section: section, index: index) { perfume in
                        presenter.perfumeTapped(perfume)
                    }
                }
            }
        case .empty:
            makeMessage(
                title: L10n.PersonalPerfume.Empty.title,
                subtitle: L10n.PersonalPerfume.Empty.subtitle,
                canRetry: false,
                canSkip: false
            )
        case .missingProfileCalculation:
            makeMessage(
                title: L10n.PersonalPerfume.Error.MissingProfile.title,
                subtitle: L10n.PersonalPerfume.Error.MissingProfile.subtitle,
                canRetry: false,
                canSkip: presenter.isPresentedInOnboarding
            )
        case .requestFailed:
            makeMessage(
                title: L10n.PersonalPerfume.Error.RequestFailed.title,
                subtitle: L10n.PersonalPerfume.Error.RequestFailed.subtitle,
                canRetry: true,
                canSkip: presenter.isPresentedInOnboarding
            )
        }
    }

    private func makeMessage(title: String, subtitle: String, canRetry: Bool, canSkip: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(.textPrimary))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
                    .lineSpacing(3)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color(.textPrimary).opacity(0.035))

            if canRetry {
                PerfumePrimaryButton(title: L10n.PersonalPerfume.retryButton) {
                    Task { await presenter.retryButtonTapped() }
                }
            }

            if canSkip {
                Button {
                    presenter.skipButtonTapped()
                } label: {
                    Text(L10n.PersonalPerfume.skipButton)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(.textPrimary))
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .overlay {
                            Rectangle().stroke(Color(.inputBorder), lineWidth: 1)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct PersonalPerfumeCollectionSection: View {
    let section: PersonalPerfumeSection
    let index: Int
    let onSelect: (PersonalPerfumeItem) -> Void

    @State private var visiblePerfumeID: Int?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .fill(Color(.inputBorder))
                    .frame(height: 1)
                    .accessibilityHidden(true)

                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(section.title)
                        .font(.title2.weight(.semibold))
                        .tracking(-0.4)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Spacer(minLength: 0)

                    Text(String(format: "%02d", index + 1))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color(.descriptionText))
                        .accessibilityHidden(true)
                }
                .foregroundStyle(Color(.textPrimary))

                Text(section.description)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 28) {
                    ForEach(section.perfumes, id: \.id) { perfume in
                        PersonalPerfumeCard(perfume: perfume) { onSelect(perfume) }
                    }
                }
                .padding(.horizontal, 24)
            } else {
                carousel
            }
        }
    }

    private var carousel: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(section.perfumes, id: \.id) { perfume in
                        PersonalPerfumeCard(perfume: perfume) { onSelect(perfume) }
                            .frame(width: 216)
                            .id(perfume.id)
                            .scrollTransition(.interactive, axis: .horizontal) { [reduceMotion] content, phase in
                                content
                                    .opacity(reduceMotion || phase.isIdentity ? 1 : 0.8)
                                    .scaleEffect(reduceMotion || phase.isIdentity ? 1 : 0.98)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 24, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $visiblePerfumeID, anchor: .leading)

            if section.perfumes.count > 1 {
                HStack(alignment: .firstTextBaseline) {
                    Text(L10n.PersonalPerfume.swipeHint)
                    Spacer(minLength: 12)
                    Text(String(format: "%02d / %02d", visibleIndex + 1, section.perfumes.count))
                        .monospacedDigit()
                        .fixedSize()
                }
                .font(.caption)
                .foregroundStyle(Color(.descriptionText))
                .padding(.horizontal, 24)
            }
        }
    }

    private var visibleIndex: Int {
        section.perfumes.firstIndex { $0.id == visiblePerfumeID } ?? 0
    }
}

private struct PersonalPerfumeCard: View {
    let perfume: PersonalPerfumeItem
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Reserved for a product photograph; intentionally blank until images are supplied.
                Rectangle()
                    .fill(Color(.textPrimary).opacity(0.035))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 7) {
                    Text(perfume.name.uppercased())
                        .font(.caption.weight(.medium))
                        .tracking(0.8)
                        .foregroundStyle(Color(.descriptionText))

                    Text(perfume.subtitle)
                        .font(.title3.weight(.medium))
                        .tracking(-0.3)
                }
                .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(L10n.PersonalPerfume.matchFormat(perfume.matchPercentage))
                        .font(.caption.weight(.medium))
                        .monospacedDigit()
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.subheadline)
                        .accessibilityHidden(true)
                }
                .padding(.top, 12)
                .overlay(alignment: .top) {
                    Rectangle().fill(Color(.inputBorder)).frame(height: 1)
                }
            }
            .foregroundStyle(Color(.textPrimary))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PersonalPerfumeCardStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(perfume.name), \(perfume.subtitle), \(L10n.PersonalPerfume.matchFormat(perfume.matchPercentage))"
        )
        .accessibilityHint(L10n.PersonalPerfume.openDetailsHint)
    }
}

private struct PersonalPerfumeCardStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
