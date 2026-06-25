//
//  SearchPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol SearchPerfumePresenter {
    func onAppear() async
    func searchTextChanged(_ searchText: String) async
    func searchSubmitted() async
    func perfumeItemAppeared(at index: Int) async
}

final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    private let searchPerfumeService: SearchPerfumeService
    private let pageSize = 10
    @MainActor private var activeRequestID = UUID()
    
    init(
        viewModel: SearchPerfumeViewModel,
        router: SearchPerfumeRouter,
        searchPerfumeService: SearchPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.searchPerfumeService = searchPerfumeService
    }
}

extension SearchPerfumePresenterImpl: SearchPerfumePresenter {
    func onAppear() async {
        guard !viewModel.hasLoadedOnce else { return }
        await loadPerfumes(resetResults: true)
    }

    func searchTextChanged(_ searchText: String) async {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedSearchText != viewModel.activeSearchText || !viewModel.hasLoadedOnce else {
            return
        }

        await loadPerfumes(resetResults: true)
    }

    func searchSubmitted() async {
        await loadPerfumes(resetResults: true)
    }

    func perfumeItemAppeared(at index: Int) async {
        guard index == viewModel.perfumes.count - 1 else { return }
        guard viewModel.canLoadMore else { return }
        guard viewModel.errorMessage == nil else { return }
        guard !viewModel.isLoading, !viewModel.isLoadingMore else { return }

        await loadPerfumes(resetResults: false)
    }
}

private extension SearchPerfumePresenterImpl {
    func loadPerfumes(resetResults: Bool) async {
        let searchText = resetResults
            ? viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            : viewModel.activeSearchText
        let offset = resetResults ? 0 : viewModel.perfumes.count
        let requestID = await MainActor.run { () -> UUID in
            viewModel.errorMessage = nil

            if resetResults {
                let newRequestID = UUID()
                activeRequestID = newRequestID
                viewModel.isLoading = true
                viewModel.canLoadMore = false
                return newRequestID
            } else {
                viewModel.isLoadingMore = true
                return activeRequestID
            }
        }

        do {
            let result = try await searchPerfumeService.requestPerfumes(
                searchText: searchText,
                offset: offset,
                limit: pageSize
            )

            await MainActor.run {
                guard requestID == activeRequestID else { return }

                if resetResults {
                    viewModel.perfumes = result.items
                    viewModel.activeSearchText = searchText
                } else {
                    viewModel.perfumes.append(contentsOf: result.items)
                }

                viewModel.canLoadMore = result.hasMore
                viewModel.errorMessage = nil
                viewModel.hasLoadedOnce = true
                viewModel.isLoading = false
                viewModel.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                guard requestID == activeRequestID else { return }

                if resetResults {
                    viewModel.perfumes = []
                    viewModel.canLoadMore = false
                }

                viewModel.errorMessage = L10n.Common.Error.message
                viewModel.hasLoadedOnce = true
                viewModel.isLoading = false
                viewModel.isLoadingMore = false
            }
        }
    }
}
