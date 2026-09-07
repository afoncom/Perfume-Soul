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
        guard !viewModel.hasLoadedOnce else { return }
        await loadPerfumeDetails()
    }

    func retryTapped() async {
        await loadPerfumeDetails()
    }

    func savePerfume(brandName: String) {
        collectionService.save(
            PerfumeCollectionPerfume(
                id: viewModel.perfume.id,
                perfumeName: viewModel.perfume.name,
                brandName: brandName,
                source: .manual
            )
        )
    }
}

extension PerfumeDetailsPresenterImpl {
    private func loadPerfumeDetails() async {
        guard !viewModel.isLoading else { return }

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
