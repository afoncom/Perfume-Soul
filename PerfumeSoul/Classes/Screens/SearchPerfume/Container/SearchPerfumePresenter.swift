//
//  SearchPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

@MainActor
protocol SearchPerfumePresenter {
    func onAppear() async
    func searchTextChanged(_ searchText: String)
    func searchSubmitted() async
    func selectTab(_ tab: CatalogTab) async
    func savedScopeChanged() async
    func selectBrand(_ brand: CatalogBrand?) async
    func retry() async
    func perfumeItemAppeared(id: Int) async
    func perfumeTapped(_ perfume: CatalogPerfume)
    func toggleSaved(_ perfume: CatalogPerfume)
    func toggleBrand(_ brand: CatalogBrand)
}

@MainActor
final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    private let catalogService: CatalogService
    private let searchPerfumeService: SearchPerfumeService
    private let collectionService: PerfumeCollectionService
    private let favoritesStorage: CatalogFavoritesStorage
    private var searchTask: Task<Void, Never>?
    private var activeRequestID = UUID()
    private var handledQuery = ""
    
    init(
        viewModel: SearchPerfumeViewModel,
        router: SearchPerfumeRouter,
        catalogService: CatalogService,
        searchPerfumeService: SearchPerfumeService,
        collectionService: PerfumeCollectionService,
        favoritesStorage: CatalogFavoritesStorage
    ) {
        self.viewModel = viewModel
        self.router = router
        self.catalogService = catalogService
        self.searchPerfumeService = searchPerfumeService
        self.collectionService = collectionService
        self.favoritesStorage = favoritesStorage
    }
}

extension SearchPerfumePresenterImpl: SearchPerfumePresenter {
    func onAppear() async {
        refreshSaved()
        viewModel.favoriteBrandIDs = favoritesStorage.load()
        if viewModel.isShowingBrands {
            await loadBrands()
        } else if viewModel.tab == .perfumes, !viewModel.hasLoadedOnce {
            await loadPerfumes(reset: true)
        }
    }

    func searchTextChanged(_ searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query != handledQuery else {
            return
        }
        handledQuery = query
        invalidateSearch()
        guard viewModel.tab == .perfumes else {
            return
        }
        viewModel.perfumes = []
        viewModel.isLoading = true
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                await self?.loadPerfumes(reset: true)
            } catch { }
        }
    }

    func searchSubmitted() async {
        invalidateSearch()
        guard viewModel.tab == .perfumes else {
            return
        }
        await loadPerfumes(reset: true, logsUnfoundSearch: true)
    }

    func selectTab(_ tab: CatalogTab) async {
        invalidateSearch()
        viewModel.tab = tab
        viewModel.selectedBrand = nil
        refreshSaved()
        if viewModel.isShowingBrands {
            await loadBrands()
        } else if tab == .perfumes {
            await loadPerfumes(reset: true)
        }
    }

    func savedScopeChanged() async {
        if viewModel.isShowingBrands { await loadBrands() }
    }

    func selectBrand(_ brand: CatalogBrand?) async {
        invalidateSearch()
        viewModel.selectedBrand = brand
        viewModel.tab = .perfumes
        handledQuery = ""
        viewModel.searchText = ""
        await loadPerfumes(reset: true)
    }

    func retry() async {
        guard !viewModel.isLoading, !viewModel.isLoadingMore else {
            return
        }
        if viewModel.isShowingBrands {
            await loadBrands()
        } else {
            await loadPerfumes(reset: viewModel.perfumes.isEmpty)
        }
    }

    func perfumeItemAppeared(id: Int) async {
        guard viewModel.tab == .perfumes,
            id == viewModel.perfumes.last?.id,
            viewModel.canLoadMore,
            !viewModel.isLoading,
            !viewModel.isLoadingMore,
            viewModel.errorMessage == nil else {
            return
        }
        await loadPerfumes(reset: false)
    }

    func perfumeTapped(_ perfume: CatalogPerfume) {
        router.showPerfumeDetailsScreen(perfume: perfume.searchItem)
    }

    func toggleSaved(_ perfume: CatalogPerfume) {
        if viewModel.savedIDs.contains(perfume.id) {
            collectionService.removeSavedPerfume(id: perfume.id)
        } else {
            collectionService.save(
                PerfumeCollectionPerfume(
                    id: perfume.id,
                    perfumeName: perfume.name,
                    brandName: perfume.brand,
                    source: .manual,
                    imageURL: perfume.imageURL
                )
            )
        }
        refreshSaved()
    }

    func toggleBrand(_ brand: CatalogBrand) {
        if viewModel.favoriteBrandIDs.contains(brand.id) {
            viewModel.favoriteBrandIDs.remove(brand.id)
        } else {
            viewModel.favoriteBrandIDs.insert(brand.id)
        }
        favoritesStorage.save(viewModel.favoriteBrandIDs)
    }

    private func refreshSaved() {
        viewModel.savedPerfumes = collectionService.loadState().savedPerfumes
    }

    private func invalidateSearch() {
        searchTask?.cancel()
        activeRequestID = UUID()
        viewModel.isLoading = false
        viewModel.isLoadingMore = false
        viewModel.canLoadMore = false
        viewModel.errorMessage = nil
    }

    private func loadBrands() async {
        guard !viewModel.isLoadingBrands, !viewModel.hasLoadedBrands else {
            return
        }
        viewModel.isLoadingBrands = true
        viewModel.brandsErrorMessage = nil
        defer { viewModel.isLoadingBrands = false }
        do {
            viewModel.brands = try await catalogService.brands()
            viewModel.hasLoadedBrands = true
        } catch {
            viewModel.brandsErrorMessage = L10n.Common.Error.message
        }
    }

    private func loadPerfumes(reset: Bool, logsUnfoundSearch: Bool = false) async {
        let requestID = reset ? UUID() : activeRequestID
        activeRequestID = requestID
        let query = viewModel.query
        let brandID = viewModel.selectedBrand?.id
        let offset = reset ? 0 : viewModel.perfumes.count
        viewModel.errorMessage = nil
        if reset {
            viewModel.isLoading = true
            viewModel.isLoadingMore = false
            viewModel.perfumes = []
        } else {
            viewModel.isLoadingMore = true
        }
        do {
            let page = try await catalogService.perfumes(search: query, brandID: brandID, offset: offset)
            guard requestID == activeRequestID, !Task.isCancelled else {
                return
            }
            if reset {
                viewModel.perfumes = page.items
            } else {
                viewModel.perfumes.append(contentsOf: page.items)
            }
            viewModel.canLoadMore = page.hasMore
            viewModel.hasLoadedOnce = true
            viewModel.isLoading = false
            viewModel.isLoadingMore = false
            if logsUnfoundSearch, reset, page.items.isEmpty, brandID == nil {
                await searchPerfumeService.recordUnfoundSearch(query: query, context: .library)
            }
        } catch {
            guard requestID == activeRequestID else {
                return
            }
            viewModel.errorMessage = L10n.Common.Error.message
            viewModel.isLoading = false
            viewModel.isLoadingMore = false
        }
    }
}
