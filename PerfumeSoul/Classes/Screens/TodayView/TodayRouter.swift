//
//  TodayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol TodayRouter {
    func showTodayEnergyScreen()
    func showDayInPerfumeryScreen() 
}

final class TodayRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension TodayRouterImpl: TodayRouter {
    func showTodayEnergyScreen() {
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(
            TodayEnergyModule.build(navigationController: navigationController),
            animated: true
        )
    }
    
    func showDayInPerfumeryScreen() {
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(
            DayInPerfumeryModule.build(navigationController: navigationController),
            animated: true
        )
    }
}
