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
    func cancelSearch()
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
    private var searchTask: Task<Void, Never>?
    private var activeSearchRequestID = UUID()
    private var activeComparisonRequestID = UUID()
    
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
        cancelSearch()

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        viewModel.isSearching = true
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(350))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }
            await self?.loadSearchResults(searchText: searchText)
        }
    }

    func searchResultTapped(
        _ perfume: SearchPerfumeItem,
        for field: ComparePerfumeField
    ) {
        cancelSearch()
        clearComparisonState()
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

    func cancelSearch() {
        searchTask?.cancel()
        activeSearchRequestID = UUID()
        viewModel.searchResults = []
        viewModel.isSearching = false
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

extension ComparePerfumesPresenterImpl {
    private func loadSearchResults(searchText: String) async {
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

            if result.items.isEmpty {
                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    return
                }
                guard requestID == activeSearchRequestID else {
                    return
                }
                await searchPerfumeService.recordUnfoundSearch(
                    query: trimmedSearchText,
                    context: .compare
                )
            }
        } catch {
            guard requestID == activeSearchRequestID else {
                return
            }

            viewModel.searchResults = []
            viewModel.isSearching = false
            viewModel.searchErrorMessage = L10n.Common.Error.message
        }
    }

    private func loadComparison(selection: ComparePerfumeSelection) async {
        let requestID = UUID()
        activeComparisonRequestID = requestID

        viewModel.isLoading = true
        viewModel.errorMessage = nil

        do {
            async let leftPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.leftPerfumeID)
            async let rightPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.rightPerfumeID)

            let result = try await (leftPerfume, rightPerfume)

            guard requestID == activeComparisonRequestID else {
                return
            }

            viewModel.leftPerfume = result.0
            viewModel.rightPerfume = result.1
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = true
            viewModel.errorMessage = nil
        } catch {
            guard requestID == activeComparisonRequestID else {
                return
            }

            viewModel.leftPerfume = nil
            viewModel.rightPerfume = nil
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = false
            viewModel.errorMessage = L10n.ComparePerfumes.loadErrorMessage
        }
    }

    private func clearComparisonState() {
        activeComparisonRequestID = UUID()
        viewModel.leftPerfume = nil
        viewModel.rightPerfume = nil
        viewModel.isLoading = false
        viewModel.hasLoadedOnce = false
        viewModel.errorMessage = nil
    }

    private func showValidationMessage(_ message: String) {
        viewModel.validationMessage = message
        viewModel.isShowingValidationAlert = true
    }
}
