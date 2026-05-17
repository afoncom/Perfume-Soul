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
    private let similarPerfumeService: SimilarPerfumeService
    
    init(
        viewModel: FindPerfumesViewModel,
        router: FindPerfumesRouter,
        similarPerfumeService: SimilarPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.similarPerfumeService = similarPerfumeService
    }
}

extension FindPerfumesPresenterImpl: FindPerfumesPresenter {
    func onAppear() async {
        do {
            let similarPerfumes = try await similarPerfumeService.requestSimilarPerfumes()
            await MainActor.run {
                viewModel.similarPerfumes = similarPerfumes
            }
        } catch {
            print(error)
        }
    }

    func findSimilarPerfumesButtonTapped() {
        router.showSimilarPerfumesScreen(similarPerfumes: viewModel.similarPerfumes)
    }
}
