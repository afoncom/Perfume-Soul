//
//  TodayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol TodayRouter {
    func showTodayEnergyScreen()
    func showDayInPerfumeryScreen(historyFact: PerfumeInHistoryResponse)
}

final class TodayRouterImpl {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension TodayRouterImpl: TodayRouter {
    func showTodayEnergyScreen() {
        navigationController?.pushViewController(
            TodayEnergyModule.build(navigationController: navigationController),
            animated: true
        )
    }
    
    func showDayInPerfumeryScreen(historyFact: PerfumeInHistoryResponse) {
        navigationController?.pushViewController(
            DayInPerfumeryModule.build(
                navigationController: navigationController,
                historyFact: historyFact
            ),
            animated: true
        )
    }
}
