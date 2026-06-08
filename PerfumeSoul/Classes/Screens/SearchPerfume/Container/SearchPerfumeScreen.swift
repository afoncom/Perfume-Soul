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
    @FocusState private var isSearchFieldFocused: Bool
    private let presenter: SearchPerfumePresenter
    
    init(
        viewModel: SearchPerfumeViewModel,
        presenter: SearchPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                makeSearchBar()
                makeResultsSection()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .task {
            await presenter.onAppear()
            try? await Task.sleep(for: .milliseconds(300))
            isSearchFieldFocused = true
        }
    }
}

extension SearchPerfumeScreen {
    func makeSearchBar() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(Color(.textSecondary))

            TextField(L10n.SearchPerfume.searchTextPlaceholder, text: $viewModel.searchText)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color(.textPrimary))
                .onSubmit {
                    Task {
                        await presenter.searchSubmitted()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""

                    Task {
                        await presenter.searchSubmitted()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(.textSecondary))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(.surfacePrimary))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
    }

    @ViewBuilder
    func makeResultsSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if viewModel.isLoading, viewModel.perfumes.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if let errorMessage = viewModel.errorMessage, viewModel.perfumes.isEmpty {
                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(Color(.textSecondary))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else if viewModel.perfumes.isEmpty, viewModel.hasLoadedOnce {
                Text(L10n.SearchPerfume.emptyState)
                    .font(.body)
                    .foregroundStyle(Color(.textSecondary))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(Array(viewModel.perfumes.enumerated()), id: \.offset) { index, perfume in
                    Text(perfume.name)
                        .font(.body)
                        .foregroundStyle(Color(.textPrimary))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.surfacePrimary))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(.cardBorder), lineWidth: 1)
                        )
                        .onAppear {
                            Task {
                                await presenter.perfumeItemAppeared(at: index)
                            }
                        }
                }

                makeLoadMoreIndicator()

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
    }

    @ViewBuilder
    func makeLoadMoreIndicator() -> some View {
        if viewModel.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}
