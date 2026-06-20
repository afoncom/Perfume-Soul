//
//  ComparePerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol ComparePerfumesPresenter {
    func searchTextChanged(_ searchText: String, for field: ComparePerfumeField) async
    func searchResultTapped(_ perfume: SearchPerfumeItem, for field: ComparePerfumeField)
    func compareTapped() async
    func retryTapped() async
}

@MainActor
final class ComparePerfumesPresenterImpl {
    private let viewModel: ComparePerfumesViewModel
    private let router: ComparePerfumesRouter
    private let comparePerfumeService: ComparePerfumeService
    private let searchPerfumeService: SearchPerfumeService
    private let comparePerfumeSelectionService: ComparePerfumeSelectionService
    private let pageSize = 10
    private var activeSearchRequestID = UUID()
    
    init(
        viewModel: ComparePerfumesViewModel,
        router: ComparePerfumesRouter,
        comparePerfumeService: ComparePerfumeService,
        searchPerfumeService: SearchPerfumeService,
        comparePerfumeSelectionService: ComparePerfumeSelectionService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.comparePerfumeService = comparePerfumeService
        self.searchPerfumeService = searchPerfumeService
        self.comparePerfumeSelectionService = comparePerfumeSelectionService
    }
}

extension ComparePerfumesPresenterImpl: ComparePerfumesPresenter {
    func searchTextChanged(_ searchText: String, for field: ComparePerfumeField) async {
        updateSelectedPerfumeIfNeeded(for: field, searchText: searchText)
        clearComparisonState()

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.searchResults = []
            viewModel.isSearching = false
            viewModel.searchErrorMessage = nil
            return
        }

        await loadSearchResults(searchText: searchText)
    }

    func searchResultTapped(
        _ perfume: SearchPerfumeItem,
        for field: ComparePerfumeField
    ) {
        switch field {
        case .left:
            viewModel.leftSearchText = perfume.name
            viewModel.leftSelectedPerfume = perfume
        case .right:
            viewModel.rightSearchText = perfume.name
            viewModel.rightSelectedPerfume = perfume
        }

        viewModel.searchResults = []
        viewModel.searchErrorMessage = nil
    }

    func compareTapped() async {
        guard
            let leftPerfume = viewModel.leftSelectedPerfume,
            let rightPerfume = viewModel.rightSelectedPerfume
        else {
            showValidationMessage(L10n.ComparePerfumes.selectionValidationMessage)
            return
        }

        guard leftPerfume.id != rightPerfume.id else {
            showValidationMessage(L10n.ComparePerfumes.samePerfumesValidationMessage)
            return
        }

        let selection = ComparePerfumeSelection(
            leftPerfumeID: leftPerfume.id,
            rightPerfumeID: rightPerfume.id
        )
        comparePerfumeSelectionService.saveSelection(selection)

        await loadComparison(selection: selection)
    }

    func retryTapped() async {
        guard
            let leftPerfume = viewModel.leftSelectedPerfume,
            let rightPerfume = viewModel.rightSelectedPerfume
        else {
            return
        }

        let selection = ComparePerfumeSelection(
            leftPerfumeID: leftPerfume.id,
            rightPerfumeID: rightPerfume.id
        )
        comparePerfumeSelectionService.saveSelection(selection)

        await loadComparison(selection: selection)
    }
}

private extension ComparePerfumesPresenterImpl {
    func loadSearchResults(searchText: String) async {
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

    func loadComparison(selection: ComparePerfumeSelection) async {
        guard !viewModel.isLoading else { return }

        viewModel.isLoading = true
        viewModel.errorMessage = nil

        do {
            async let leftPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.leftPerfumeID)
            async let rightPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.rightPerfumeID)

            let result = try await (leftPerfume, rightPerfume)

            viewModel.leftPerfume = result.0
            viewModel.rightPerfume = result.1
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = true
            viewModel.errorMessage = nil
        } catch {
            viewModel.leftPerfume = nil
            viewModel.rightPerfume = nil
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = false
            viewModel.errorMessage = L10n.ComparePerfumes.loadErrorMessage
        }
    }

    func updateSelectedPerfumeIfNeeded(
        for field: ComparePerfumeField,
        searchText: String
    ) {
        switch field {
        case .left:
            if viewModel.leftSelectedPerfume?.name != searchText {
                viewModel.leftSelectedPerfume = nil
            }
        case .right:
            if viewModel.rightSelectedPerfume?.name != searchText {
                viewModel.rightSelectedPerfume = nil
            }
        }
    }

    func clearComparisonState() {
        viewModel.leftPerfume = nil
        viewModel.rightPerfume = nil
        viewModel.hasLoadedOnce = false
        viewModel.errorMessage = nil
    }

    func showValidationMessage(_ message: String) {
        viewModel.validationMessage = message
        viewModel.isShowingValidationAlert = true
    }
}
