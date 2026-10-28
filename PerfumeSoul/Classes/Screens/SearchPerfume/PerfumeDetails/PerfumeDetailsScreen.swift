//
//  PerfumeDetailsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import SwiftUI

struct PerfumeDetailsScreen: View {
    @Bindable private var viewModel: PerfumeDetailsViewModel
    @State private var selectedSection: PerfumeDetailsSection = .about
    @State private var isStoryExpanded = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let presenter: PerfumeDetailsPresenter

    init(viewModel: PerfumeDetailsViewModel, presenter: PerfumeDetailsPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if viewModel.isLoading {
                    ProgressView(L10n.PerfumeDetails.loadingMessage)
                        .frame(maxWidth: .infinity, minHeight: 360)
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(Color(.textSecondary))
                        .padding(.top, 60)
                    PerfumePrimaryButton(title: L10n.PerfumeDetails.retryButton) {
                        Task { await presenter.retryTapped() }
                    }
                } else if let details = viewModel.perfumeDetails {
                    productHeader(details)
                    sectionPicker
                    sectionContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 36)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let details = viewModel.perfumeDetails, !viewModel.isLoading {
                saveAction(brand: details.brand)
            }
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .tint(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .task { await presenter.onAppear() }
    }

    private func productHeader(_ details: PerfumeDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: viewModel.imageURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Rectangle().fill(Color(.placeholderSoft))
            }
                .aspectRatio(dynamicTypeSize.isAccessibilitySize ? 1.6 : 1, contentMode: .fit)
                .overlay { Rectangle().stroke(Color(.cardBorder), lineWidth: 1) }
                .accessibilityHidden(true)
            Text(details.brand.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.4)
                .padding(.top, 8)
            Text(details.name)
                .font(.largeTitle.weight(.medium))
                .tracking(-1)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let concentration = viewModel.concentration {
                Text(concentration)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
            }
        }
    }

    private var sectionPicker: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
        return layout {
            ForEach(PerfumeDetailsSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) {
                        selectedSection = section
                    }
                } label: {
                    Text(section.title)
                        .font(.subheadline.weight(selectedSection == section ? .semibold : .regular))
                        .foregroundStyle(selectedSection == section ? Color(.textPrimary) : Color(.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(selectedSection == section ? Color(.textPrimary) : Color(.cardBorder))
                                .frame(height: selectedSection == section ? 2 : 1)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedSection == section ? .isSelected : [])
            }
        }
    }

    @ViewBuilder private var sectionContent: some View {
        switch selectedSection {
        case .about:
            VStack(alignment: .leading, spacing: 28) {
                Text(viewModel.summary)
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                if !viewModel.accords.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        caption(L10n.PerfumeDetails.mainAccordsTitle)
                        Text(viewModel.accords.joined(separator: " · "))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if !viewModel.facts.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(viewModel.facts, id: \.title) { fact in
                            factRow(title: fact.title, value: fact.value)
                            rule
                        }
                    }
                }
                if let story = viewModel.story {
                    DisclosureGroup(L10n.PerfumeDetails.historyTitle, isExpanded: $isStoryExpanded) {
                        Text(story)
                            .font(.body)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 12)
                    }
                    .font(.subheadline.weight(.medium))
                }
                if let recommendation = viewModel.recommendation {
                    DisclosureGroup(L10n.PerfumeDetails.recommendationReasonTitle) {
                        Text(recommendation)
                            .font(.body)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 12)
                    }
                    .font(.subheadline.weight(.medium))
                }
            }
        case .notes:
            if viewModel.hasLocalizedNotes {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(viewModel.noteRows, id: \.title) { row in
                        VStack(alignment: .leading, spacing: 12) {
                            caption(row.title)
                            Text(row.notes)
                                .font(.title3)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .combine)
                        rule
                    }
                }
            } else {
                Text(String(localized: "perfumeDetails.notesUnavailable"))
                    .font(.body)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .wear:
            VStack(spacing: 28) {
                ForEach(viewModel.wearRows, id: \.title) { row in
                    VStack(alignment: .leading, spacing: 12) {
                        factRow(title: row.title, value: viewModel.scoreText(row.score))
                        if let score = row.score, (0...10).contains(score) {
                            ProgressView(value: Double(score), total: 10)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func saveAction(brand: String) -> some View {
        Button {
            presenter.savePerfume(brandName: brand)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: viewModel.isSaved ? "heart.fill" : "heart")
                    .accessibilityHidden(true)
                Text(viewModel.isSaved ? String(localized: "catalog.unsave") : String(localized: "catalog.save"))
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .foregroundStyle(Color(.backgroundPrimary))
            .background(Color(.textPrimary))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(.backgroundPrimary))
        .overlay(alignment: .top) { rule }
    }

    private func factRow(title: String, value: String) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 20))
        return layout {
            Text(title).foregroundStyle(Color(.textSecondary))
            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 0) }
            Text(value).multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }

    private func caption(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.medium))
            .tracking(1)
            .foregroundStyle(Color(.textSecondary))
            .accessibilityAddTraits(.isHeader)
    }

    private var rule: some View {
        Rectangle().fill(Color(.cardBorder)).frame(height: 1)
    }
}
