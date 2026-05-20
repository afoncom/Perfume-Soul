//
//  FindPerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol FindPerfumesPresenter {
    func onAppear() async
    func findSimilarPerfumesButtonTapped()
}

final class FindPerfumesPresenterImpl {
    private let viewModel: FindPerfumesViewModel
    private let router: FindPerfumesRouter
    private let perfumeRecommendationService: PerfumeRecommendationService
    
    init(
        viewModel: FindPerfumesViewModel,
        router: FindPerfumesRouter,
        perfumeRecommendationService: PerfumeRecommendationService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeRecommendationService = perfumeRecommendationService
    }
}

extension FindPerfumesPresenterImpl: FindPerfumesPresenter {
    func onAppear() async {
        do {
            let perfumeRecommendations = try await perfumeRecommendationService.requestPerfumeRecommendations()
            await MainActor.run {
                viewModel.perfumeRecommendations = perfumeRecommendations
            }
        } catch {
            print(error)
        }
    }

    func findSimilarPerfumesButtonTapped() {
        router.showPerfumeRecommendationsScreen(perfumeRecommendations: viewModel.perfumeRecommendations)
    }
}
