//
//  SearchPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SearchPerfumePresenter {
    func searchButtonTapped() async
}

final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    private let searchPerfumeService: SearchPerfumeService
    
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
    func searchButtonTapped() async {
        let searchText = viewModel.searchText
        let page = Int(viewModel.pageText) ?? 1
        let itemsPerPage = Int(viewModel.itemsPerPageText) ?? 10

        await MainActor.run {
            viewModel.isLoading = true
            viewModel.hasSearched = true
        }

        do {
            let perfumes = try await searchPerfumeService.requestPerfumes(
                searchText: searchText,
                page: page,
                itemsPerPage: itemsPerPage
            )

            await MainActor.run {
                viewModel.perfumes = perfumes
                viewModel.isLoading = false
            }
        } catch {
            print(error)
            await MainActor.run {
                viewModel.perfumes = []
                viewModel.isLoading = false
            }
        }
    }
}
