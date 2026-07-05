//
//  FindPerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol FindPerfumesPresenter {
    func searchTextChanged(_ searchText: String, for field: FindPerfumeField) async
    func searchResultTapped(_ perfume: SearchPerfumeItem, for field: FindPerfumeField)
    func findSimilarPerfumesButtonTapped()
}

final class FindPerfumesPresenterImpl {
    private let viewModel: FindPerfumesViewModel
    private let router: FindPerfumesRouter
    private let searchPerfumeService: SearchPerfumeService
    private let pageSize = 10
    private var activeSearchRequestID = UUID()

    init(
        viewModel: FindPerfumesViewModel,
        router: FindPerfumesRouter,
        searchPerfumeService: SearchPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.searchPerfumeService = searchPerfumeService
    }
}

extension FindPerfumesPresenterImpl: FindPerfumesPresenter {
    @MainActor func searchTextChanged(_ searchText: String, for field: FindPerfumeField) async {
        updateSelectedPerfumeIfNeeded(for: field, searchText: searchText)

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activeSearchRequestID = UUID()
            viewModel.searchResults = []
            viewModel.isSearching = false
            viewModel.searchErrorMessage = nil
            return
        }

        await loadSearchResults(searchText: searchText)
    }

    @MainActor func searchResultTapped(_ perfume: SearchPerfumeItem, for field: FindPerfumeField) {
        switch field {
        case .first:
            viewModel.firstSearchText = perfume.name
            viewModel.firstSelectedPerfume = perfume
        case .second:
            viewModel.secondSearchText = perfume.name
            viewModel.secondSelectedPerfume = perfume
        case .third:
            viewModel.thirdSearchText = perfume.name
            viewModel.thirdSelectedPerfume = perfume
        }

        viewModel.searchResults = []
        viewModel.searchErrorMessage = nil
    }

    @MainActor func findSimilarPerfumesButtonTapped() {
        guard viewModel.firstSelectedPerfume != nil else {
            showValidationMessage(L10n.Discover.FindSimilar.firstPerfumeValidationMessage)
            return
        }

        guard hasValidOptionalSelections else {
            showValidationMessage(L10n.Discover.FindSimilar.selectionValidationMessage)
            return
        }

        let perfumeIDs = viewModel.selectedPerfumes.map(\.id)
        guard Set(perfumeIDs).count == perfumeIDs.count else {
            showValidationMessage(L10n.Discover.FindSimilar.samePerfumesValidationMessage)
            return
        }

        router.showPerfumeRecommendationsScreen(selectedPerfumes: viewModel.selectedPerfumes)
    }
}

extension FindPerfumesPresenterImpl {
    @MainActor private var hasValidOptionalSelections: Bool {
        isFieldValid(
            searchText: viewModel.secondSearchText,
            selectedPerfume: viewModel.secondSelectedPerfume
        )
        && isFieldValid(
            searchText: viewModel.thirdSearchText,
            selectedPerfume: viewModel.thirdSelectedPerfume
        )
    }

    @MainActor private func loadSearchResults(searchText: String) async {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let requestID = UUID()
        activeSearchRequestID = requestID

        viewModel.isSearching = true
        viewModel.searchErrorMessage = nil

        do {
            let result = try await searchPerfumeService.requestPerfumes(
                searchText: trimmedSearchText,
                offset: 0,
                limit: pageSize
            )

            guard requestID == activeSearchRequestID else {
                return
            }

            viewModel.searchResults = result.items
            viewModel.isSearching = false
            viewModel.searchErrorMessage = nil
        } catch {
            guard requestID == activeSearchRequestID else {
                return
            }

            viewModel.searchResults = []
            viewModel.isSearching = false
            viewModel.searchErrorMessage = L10n.Common.Error.message
        }
    }

    @MainActor private func updateSelectedPerfumeIfNeeded(
        for field: FindPerfumeField,
        searchText: String
    ) {
        switch field {
        case .first:
            if viewModel.firstSelectedPerfume?.name != searchText {
                viewModel.firstSelectedPerfume = nil
            }
        case .second:
            if viewModel.secondSelectedPerfume?.name != searchText {
                viewModel.secondSelectedPerfume = nil
            }
        case .third:
            if viewModel.thirdSelectedPerfume?.name != searchText {
                viewModel.thirdSelectedPerfume = nil
            }
        }
    }

    @MainActor private func isFieldValid(
        searchText: String,
        selectedPerfume: SearchPerfumeItem?
    ) -> Bool {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedSearchText.isEmpty || selectedPerfume != nil
    }

    @MainActor private func showValidationMessage(_ message: String) {
        viewModel.validationMessage = message
        viewModel.isShowingValidationAlert = true
    }
}
