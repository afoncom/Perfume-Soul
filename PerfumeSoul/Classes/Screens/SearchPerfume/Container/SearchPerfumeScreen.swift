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
    @State private var isSearchPresented = true
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
                makeResultsSection()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(L10n.Screen.searchPerfume)
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchText,
            isPresented: $isSearchPresented,
            prompt: L10n.SearchPerfume.searchTextPlaceholder
        )
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                await presenter.searchTextChanged(newValue)
            }
        }
        .onSubmit(of: .search) {
            Task {
                await presenter.searchSubmitted()
            }
        }
        .task {
            await presenter.onAppear()
            isSearchPresented = true
        }
    }
}

extension SearchPerfumeScreen {
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
                ForEach(viewModel.perfumes) { perfume in
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
                            guard let index = viewModel.perfumes.firstIndex(where: { $0.id == perfume.id }) else {
                                return
                            }

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
