//
//  SearchPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SearchPerfumeScreen: View {
    @Bindable private var viewModel: SearchPerfumeViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isSearchFocused: Bool
    private let presenter: SearchPerfumePresenter

    init(viewModel: SearchPerfumeViewModel, presenter: SearchPerfumePresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                searchField
                tabs
                if viewModel.tab == .saved {
                    Picker(String(localized: "catalog.saved"), selection: $viewModel.showsSavedBrands) {
                        Text(String(localized: "catalog.perfumes")).tag(false)
                        Text(String(localized: "catalog.brands")).tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.showsSavedBrands) { _, _ in
                        Task { await presenter.savedScopeChanged() }
                    }
                }
                if let brand = viewModel.selectedBrand {
                    HStack(spacing: 12) {
                        Text(brand.name).font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button {
                            Task { await presenter.selectBrand(nil) }
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(String(localized: "catalog.clearBrand"))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 20)

            if viewModel.isShowingBrands {
                brandContent
            } else {
                perfumeContent
            }
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .tint(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.searchText) { _, text in
            presenter.searchTextChanged(text)
        }
        .task { await presenter.onAppear() }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").accessibilityHidden(true)
            TextField(String(localized: "catalog.search"), text: $viewModel.searchText)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearchFocused)
                .onSubmit {
                    isSearchFocused = false
                    Task { await presenter.searchSubmitted() }
                }
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark").frame(width: 44, height: 44)
                }
                .accessibilityLabel(String(localized: "catalog.clearSearch"))
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, viewModel.searchText.isEmpty ? 16 : 0)
        .frame(minHeight: 52)
        .background(Color(.placeholderSoft))
    }

    private var tabs: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(spacing: 20))
        return layout {
            ForEach(CatalogTab.allCases, id: \.self) { tab in
                Button {
                    isSearchFocused = false
                    Task { await presenter.selectTab(tab) }
                } label: {
                    Text(tab.title)
                        .font(.subheadline.weight(viewModel.tab == tab ? .semibold : .regular))
                        .foregroundStyle(viewModel.tab == tab ? Color(.textPrimary) : Color(.textSecondary))
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            if viewModel.tab == tab {
                                Rectangle().fill(Color(.textPrimary)).frame(height: 2)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(viewModel.tab == tab ? .isSelected : [])
            }
        }
    }

    @ViewBuilder private var brandContent: some View {
        if viewModel.isLoadingBrands {
            loading
        } else if let error = viewModel.brandsErrorMessage {
            state(message: error, allowsRetry: true)
        } else if viewModel.brandSections.isEmpty {
            state(message: viewModel.emptyMessage)
        } else {
            CatalogBrandList(
                sections: viewModel.brandSections,
                favoriteIDs: viewModel.favoriteBrandIDs,
                onSelect: { brand in
                    isSearchFocused = false
                    Task { await presenter.selectBrand(brand) }
                },
                onFavorite: { presenter.toggleBrand($0) }
            )
        }
    }

    private var perfumeContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.tab == .perfumes && viewModel.isLoading {
                    loading
                } else if viewModel.displayedPerfumes.isEmpty {
                    state(
                        message: viewModel.tab == .perfumes
                            ? viewModel.errorMessage ?? viewModel.emptyMessage
                            : viewModel.emptyMessage,
                        allowsRetry: viewModel.tab == .perfumes && viewModel.errorMessage != nil
                    )
                } else {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2),
                        alignment: .leading,
                        spacing: 32
                    ) {
                        ForEach(viewModel.displayedPerfumes) { perfume in
                            CatalogPerfumeCard(
                                perfume: perfume,
                                isSaved: viewModel.savedIDs.contains(perfume.id),
                                onOpen: { presenter.perfumeTapped(perfume) },
                                onSave: { presenter.toggleSaved(perfume) }
                            )
                            .onAppear {
                                Task { await presenter.perfumeItemAppeared(id: perfume.id) }
                            }
                        }
                    }
                    if viewModel.isLoadingMore { ProgressView().padding(20) }
                    if viewModel.tab == .perfumes, let error = viewModel.errorMessage {
                        state(message: error, allowsRetry: true)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: viewModel.tab)
    }

    private var loading: some View {
        ProgressView()
            .frame(maxWidth: .infinity, minHeight: 240)
            .accessibilityLabel(L10n.PerfumeDetails.loadingMessage)
    }

    private func state(message: String, allowsRetry: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(message)
                .font(.body)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
            if allowsRetry {
                PerfumePrimaryButton(title: L10n.PerfumeDetails.retryButton) {
                    Task { await presenter.retry() }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
    }
}

private struct CatalogPerfumeCard: View {
    let perfume: CatalogPerfume
    let isSaved: Bool
    let onOpen: () -> Void
    let onSave: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                Rectangle()
                    .fill(Color(.placeholderSoft))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay { Rectangle().stroke(Color(.cardBorder), lineWidth: 1) }
                    .accessibilityHidden(true)
                Text(perfume.brand.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                Text(perfume.name)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Button(action: onSave) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.body)
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    .frame(width: 44, height: 44)
                    .background(Color(.backgroundPrimary))
            }
            .buttonStyle(.plain)
            .padding(6)
            .accessibilityLabel(isSaved ? String(localized: "catalog.unsave") : String(localized: "catalog.save"))
            .accessibilityValue(perfume.name)
            .transaction { if reduceMotion { $0.animation = nil } }
        }
    }
}
