//
//  PerfumeDetailsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation

protocol PerfumeDetailsPresenter {
    func onAppear() async
    func retryTapped() async
    @MainActor func savePerfume(brandName: String)
}

@MainActor
final class PerfumeDetailsPresenterImpl {
    private let viewModel: PerfumeDetailsViewModel
    private let router: PerfumeDetailsRouter
    private let perfumeDetailsService: PerfumeDetailsService
    private let collectionService: PerfumeCollectionService
    private var isLoadingImage = false
    private var hasLoadedImage = false

    init(
        viewModel: PerfumeDetailsViewModel,
        router: PerfumeDetailsRouter,
        perfumeDetailsService: PerfumeDetailsService,
        collectionService: PerfumeCollectionService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeDetailsService = perfumeDetailsService
        self.collectionService = collectionService
    }
}

extension PerfumeDetailsPresenterImpl: PerfumeDetailsPresenter {
    func onAppear() async {
        updateSavedPerfumeState()

        if !viewModel.hasLoadedOnce {
            await loadPerfumeDetails()
        }
        await loadPerfumeImage()
    }

    func retryTapped() async {
        await loadPerfumeDetails()
        await loadPerfumeImage()
    }

    func savePerfume(brandName: String) {
        if viewModel.isSaved {
            collectionService.removeSavedPerfume(id: viewModel.perfume.id)
            updateSavedPerfumeState()
            return
        }
        collectionService.save(
            PerfumeCollectionPerfume(
                id: viewModel.perfume.id,
                perfumeName: viewModel.perfumeDetails?.name ?? viewModel.perfume.name,
                brandName: brandName,
                source: .manual
            )
        )
        updateSavedPerfumeState()
    }
}

extension PerfumeDetailsPresenterImpl {
    private func loadPerfumeImage() async {
        guard viewModel.hasLoadedOnce, !isLoadingImage, !hasLoadedImage, !Task.isCancelled else {
            return
        }
        isLoadingImage = true
        defer { isLoadingImage = false }

        do {
            let imageURL = try await perfumeDetailsService.requestPerfumeImage(perfumeID: viewModel.perfume.id)
            try Task.checkCancellation()
            viewModel.imageURL = imageURL
            hasLoadedImage = true
        } catch {
            // A photo failure must not change the already loaded details or their error state.
        }
    }

    private func updateSavedPerfumeState() {
        viewModel.isSaved = collectionService.loadState().savedPerfumes.contains {
            $0.id == viewModel.perfume.id
        }
    }

    private func loadPerfumeDetails() async {
        guard !viewModel.isLoading else {
            return
        }

        viewModel.isLoading = true
        viewModel.errorMessage = nil

        do {
            let perfumeDetails = try await perfumeDetailsService.requestPerfumeDetails(
                perfumeID: viewModel.perfume.id
            )

            viewModel.perfumeDetails = perfumeDetails
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = true
            viewModel.errorMessage = nil
        } catch {
            viewModel.perfumeDetails = nil
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = false
            viewModel.errorMessage = L10n.PerfumeDetails.loadErrorMessage
        }
    }
}
