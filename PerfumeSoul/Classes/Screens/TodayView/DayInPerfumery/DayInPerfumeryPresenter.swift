//
//  DayInPerfumeryPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DayInPerfumeryPresenter {
    func refresh() async
}

final class DayInPerfumeryPresenterImpl {
    private let viewModel: DayInPerfumeryViewModel
    private let router: DayInPerfumeryRouter
    private let perfumeHistoryService: PerfumeHistoryService
    
    init(
        viewModel: DayInPerfumeryViewModel,
        router: DayInPerfumeryRouter,
        perfumeHistoryService: PerfumeHistoryService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeHistoryService = perfumeHistoryService
    }
}

extension DayInPerfumeryPresenterImpl: DayInPerfumeryPresenter {
    @MainActor
    func refresh() async {
        do {
            viewModel.historyFact = try await perfumeHistoryService.requestPerfumeHistory()
            viewModel.isUnavailable = false
        } catch {
            viewModel.isUnavailable = true
        }
    }
}
