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
    private let imageLoader: PerfumeImageLoader

    init(viewModel: SearchPerfumeViewModel, presenter: SearchPerfumePresenter, imageLoader: PerfumeImageLoader) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.imageLoader = imageLoader
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

    @ViewBuilder private var perfumeContent: some View {
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
            CatalogPerfumeList(
                perfumes: viewModel.displayedPerfumes,
                savedIDs: viewModel.savedIDs,
                columns: dynamicTypeSize.isAccessibilitySize ? 1 : 2,
                imageLoader: imageLoader,
                isLoadingMore: viewModel.isLoadingMore,
                errorMessage: viewModel.tab == .perfumes ? viewModel.errorMessage : nil,
                onOpen: { presenter.perfumeTapped($0) },
                onSave: { presenter.toggleSaved($0) },
                onAppear: { perfume in
                    Task { await presenter.perfumeItemAppeared(id: perfume.id) }
                },
                onRetry: { Task { await presenter.retry() } }
            )
        }
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
