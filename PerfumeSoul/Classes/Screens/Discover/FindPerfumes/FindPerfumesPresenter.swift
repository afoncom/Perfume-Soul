//
//  FindPerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol FindPerfumesPresenter {
    func findSimilarPerfumesButtonTapped() async
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
    func findSimilarPerfumesButtonTapped() async {
        do {
            let listPerfumes = try await listPerfumeService.requestListPerfume()
            await MainActor.run {
                router.showSimilarPerfumesScreen(listPerfumes: listPerfumes)
            }
        } catch {
            print(error)
        }
    }
}
