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
    func perfumeTapped(_ perfume: PerfumeCollectionPerfume)
    @MainActor
    func removePerfume(_ perfume: PerfumeCollectionPerfume)
}

final class CabinetPresenterImpl {
    private let viewModel: CabinetViewModel
    private let router: CabinetRouter
    private let collectionService: PerfumeCollectionService

    init(
        viewModel: CabinetViewModel,
        router: CabinetRouter,
        collectionService: PerfumeCollectionService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.collectionService = collectionService
    }
}

extension CabinetPresenterImpl: CabinetPresenter {
    func onAppear() {
        let perfumes = collectionService.loadState().savedPerfumes
        viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
    }

    @MainActor
    func perfumeTapped(_ perfume: PerfumeCollectionPerfume) {
        router.showPerfumeDetailsScreen(
            perfume: SearchPerfumeItem(id: perfume.id, name: perfume.perfumeName)
        )
    }

    @MainActor
    func removePerfume(_ perfume: PerfumeCollectionPerfume) {
        collectionService.removeSavedPerfume(id: perfume.id)
        let perfumes = collectionService.loadState().savedPerfumes
        viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
    }
}
