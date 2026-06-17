//
//  ComparePerfumesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ComparePerfumesPresenter {
    func onAppear() async
    func retryTapped() async
}

@MainActor
final class ComparePerfumesPresenterImpl {
    private let viewModel: ComparePerfumesViewModel
    private let router: ComparePerfumesRouter
    private let comparePerfumeService: ComparePerfumeService
    private let comparePerfumeSelectionService: ComparePerfumeSelectionService
    
    init(
        viewModel: ComparePerfumesViewModel,
        router: ComparePerfumesRouter,
        comparePerfumeService: ComparePerfumeService,
        comparePerfumeSelectionService: ComparePerfumeSelectionService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.comparePerfumeService = comparePerfumeService
        self.comparePerfumeSelectionService = comparePerfumeSelectionService
    }
}

extension ComparePerfumesPresenterImpl: ComparePerfumesPresenter {
    func onAppear() async {
        await loadComparison(force: false)
    }

    func retryTapped() async {
        await loadComparison(force: true)
    }
}

private extension ComparePerfumesPresenterImpl {
    func loadComparison(force: Bool) async {
        guard force || !viewModel.hasLoadedOnce else { return }
        guard !viewModel.isLoading else { return }

        guard let selection = comparePerfumeSelectionService.fetchSelection() else {
            viewModel.leftPerfume = nil
            viewModel.rightPerfume = nil
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = false
            viewModel.errorMessage = "Не выбрана пара ароматов для сравнения."
            return
        }

        viewModel.isLoading = true
        viewModel.errorMessage = nil

        do {
            async let leftPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.leftPerfumeID)
            async let rightPerfume = comparePerfumeService.requestPerfume(perfumeID: selection.rightPerfumeID)

            let result = try await (leftPerfume, rightPerfume)

            viewModel.leftPerfume = result.0
            viewModel.rightPerfume = result.1
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = true
            viewModel.errorMessage = nil
        } catch {
            viewModel.leftPerfume = nil
            viewModel.rightPerfume = nil
            viewModel.isLoading = false
            viewModel.hasLoadedOnce = false
            viewModel.errorMessage = "Не удалось загрузить данные для сравнения."
        }
    }
}
