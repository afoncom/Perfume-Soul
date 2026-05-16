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
    private let listPerfumeService: ListPerfumeService
    
    init(
        viewModel: FindPerfumesViewModel,
        router: FindPerfumesRouter,
        listPerfumeService: ListPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.listPerfumeService = listPerfumeService
    }
}

extension FindPerfumesPresenterImpl: FindPerfumesPresenter {
    func onAppear() async {
        do {
            let listPerfumes = try await listPerfumeService.requestListPerfume()
            await MainActor.run {
                viewModel.listPerfumes = listPerfumes
            }
        } catch {
            print(error)
        }
    }

    func findSimilarPerfumesButtonTapped() {
        router.showSimilarPerfumesScreen(listPerfumes: viewModel.listPerfumes)
    }
}
