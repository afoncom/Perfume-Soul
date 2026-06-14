//
//  ComparePerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ComparePerfumesPresenter {
    func onAppear() async
}

final class ComparePerfumesPresenterImpl {
    private let viewModel: ComparePerfumesViewModel
    private let router: ComparePerfumesRouter
    private let comparePerfumeService: ComparePerfumeService
    
    init(
        viewModel: ComparePerfumesViewModel,
        router: ComparePerfumesRouter,
        comparePerfumeService: ComparePerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.comparePerfumeService = comparePerfumeService
    }
}

extension ComparePerfumesPresenterImpl: ComparePerfumesPresenter {
    func onAppear() async {
        guard !viewModel.hasLoadedOnce else { return }

        await MainActor.run {
            viewModel.isLoading = true
            viewModel.errorMessage = nil
        }

        do {
            async let leftPerfume = comparePerfumeService.requestPerfume(perfumeID: 3)
            async let rightPerfume = comparePerfumeService.requestPerfume(perfumeID: 1)

            let result = try await (leftPerfume, rightPerfume)

            await MainActor.run {
                viewModel.leftPerfume = result.0
                viewModel.rightPerfume = result.1
                viewModel.isLoading = false
                viewModel.hasLoadedOnce = true
                viewModel.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                viewModel.leftPerfume = nil
                viewModel.rightPerfume = nil
                viewModel.isLoading = false
                viewModel.hasLoadedOnce = true
                viewModel.errorMessage = "Не удалось загрузить данные для сравнения."
            }
        }
    }
}
