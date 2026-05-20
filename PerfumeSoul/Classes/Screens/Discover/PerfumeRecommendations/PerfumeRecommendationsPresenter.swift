//
//  PerfumeRecommendationsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeRecommendationsPresenter {
    func onAppear() async
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
        await MainActor.run {
            viewModel.isLoading = true
        }

        do {
            let perfumeRecommendations = try await perfumeRecommendationService.requestPerfumeRecommendations()
            await MainActor.run {
                viewModel.perfumeRecommendations = perfumeRecommendations
                viewModel.isLoading = false
            }
        } catch {
            await MainActor.run {
                viewModel.isLoading = false
            }
            print(error)
        }
    }
}
