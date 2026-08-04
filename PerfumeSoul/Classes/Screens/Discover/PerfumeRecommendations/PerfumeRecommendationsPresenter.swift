//
//  PerfumeRecommendationsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeRecommendationsPresenter {
    func onAppear() async
    @MainActor
    func recommendationTapped(_ perfume: PerfumeRecommendation)
}

final class PerfumeRecommendationsPresenterImpl {
    private let viewModel: PerfumeRecommendationsViewModel
    private let router: PerfumeRecommendationsRouter
    private let perfumeRecommendationService: PerfumeRecommendationService
    
    init(
        viewModel: PerfumeRecommendationsViewModel,
        router: PerfumeRecommendationsRouter,
        perfumeRecommendationService: PerfumeRecommendationService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeRecommendationService = perfumeRecommendationService
    }
}

extension PerfumeRecommendationsPresenterImpl: PerfumeRecommendationsPresenter {
    func onAppear() async {
        let shouldLoad = await MainActor.run {
            guard !viewModel.hasLoadedRecommendations, !viewModel.isLoading else {
                return false
            }

            viewModel.isLoading = true
            viewModel.errorMessage = nil
            return true
        }
        guard shouldLoad else {
            return
        }

        do {
            let perfumeRecommendations = try await perfumeRecommendationService.requestPerfumeRecommendations(
                perfumeIDs: viewModel.selectedPerfumes.map(\.id)
            )

            await MainActor.run {
                viewModel.perfumeRecommendations = perfumeRecommendations
                viewModel.hasLoadedRecommendations = true
                viewModel.isLoading = false
                viewModel.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                viewModel.perfumeRecommendations = []
                viewModel.isLoading = false
                viewModel.errorMessage = L10n.Common.Error.message
            }
        }
    }

    @MainActor func recommendationTapped(_ perfume: PerfumeRecommendation) {
        let fullName: String

        if perfume.perfumeName.localizedCaseInsensitiveContains(perfume.brandName), !perfume.brandName.isEmpty {
            fullName = perfume.perfumeName
        } else if perfume.brandName.isEmpty {
            fullName = perfume.perfumeName
        } else {
            fullName = "\(perfume.brandName) \(perfume.perfumeName)"
        }

        router.showPerfumeDetailsScreen(
            perfume: SearchPerfumeItem(
                id: perfume.id,
                name: fullName
            )
        )
    }
}
