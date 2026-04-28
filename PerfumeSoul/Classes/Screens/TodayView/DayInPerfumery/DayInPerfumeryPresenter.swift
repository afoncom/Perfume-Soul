//
//  DayInPerfumeryPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DayInPerfumeryPresenter {
    func onAppear() async
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
    func onAppear() async {
        do {
            try await perfumeHistoryService.requestPerfumeHistory()
        } catch let error {
            print(error)
        }
        print("Work")
    }
}
