//
//  CabinetPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CabinetPresenter {
    func onAppear()
    @MainActor
    func perfumeTapped(_ perfume: DailyPerfumeSummary)
    @MainActor
    func removePerfume(_ perfume: DailyPerfumeSummary)
}

final class CabinetPresenterImpl {
    private let viewModel: CabinetViewModel
    private let router: CabinetRouter
    private let stateStorage: DailyPerfumeStateStorage

    init(
        viewModel: CabinetViewModel,
        router: CabinetRouter,
        stateStorage: DailyPerfumeStateStorage
    ) {
        self.viewModel = viewModel
        self.router = router
        self.stateStorage = stateStorage
    }
}

extension CabinetPresenterImpl: CabinetPresenter {
    func onAppear() {
        let perfumes = stateStorage.loadState()?.savedPerfumes ?? []
        viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
    }

    @MainActor
    func perfumeTapped(_ perfume: DailyPerfumeSummary) {
        router.showPerfumeDetailsScreen(
            perfume: SearchPerfumeItem(id: perfume.id, name: perfume.perfumeName)
        )
    }

    @MainActor
    func removePerfume(_ perfume: DailyPerfumeSummary) {
        guard var state = stateStorage.loadState() else {
            return
        }

        state.savedPerfumes.removeAll { $0.id == perfume.id }
        stateStorage.saveState(state)

        let perfumes = state.savedPerfumes
        viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
    }
}
