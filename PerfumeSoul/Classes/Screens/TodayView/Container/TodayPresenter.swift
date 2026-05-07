//
//  TodayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

protocol TodayPresenter {
    func onAppear() async
    func todayEnergyButtonTab()
    func dayInPerfumeryButtonTab()
}

final class TodayPresenterImpl {
    private let viewModel: TodayViewModel
    private let router: TodayRouter
    private let perfumeHistoryService: PerfumeHistoryService
    
    init(
        viewModel: TodayViewModel,
        router: TodayRouter,
        perfumeHistoryService: PerfumeHistoryService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeHistoryService = perfumeHistoryService
    }
}

extension TodayPresenterImpl: TodayPresenter {
    @MainActor
    func onAppear() async {
        viewModel.viewState = .loading
        do {
            let result = try await perfumeHistoryService.requestPerfumeHistory()
            viewModel.viewState = .loaded(historyFact: result)
            print(result)
        } catch let error {
            print(error)
        }
    }

    func todayEnergyButtonTab() {
        router.showTodayEnergyScreen()
    }
    
    func dayInPerfumeryButtonTab() {
        guard case let .loaded(historyFact) = viewModel.viewState else { return }
        router.showDayInPerfumeryScreen(historyFact: historyFact)
    }
}
