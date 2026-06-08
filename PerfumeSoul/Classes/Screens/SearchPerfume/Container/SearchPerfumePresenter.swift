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
    func searchSubmitted() async
    func perfumeItemAppeared(at index: Int) async
}

final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    private let searchPerfumeService: SearchPerfumeService
    private let pageSize = 10
    
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

        await MainActor.run {
            viewModel.errorMessage = nil

            if resetResults {
                viewModel.isLoading = true
                viewModel.canLoadMore = false
            } else {
                viewModel.isLoadingMore = true
            }
        }

        if !resetResults {
            try? await Task.sleep(for: .seconds(2))
        }

        do {
            let result = try await searchPerfumeService.requestPerfumes(
                searchText: searchText,
                offset: offset,
                limit: pageSize
            )

            await MainActor.run {
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
