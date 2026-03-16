//
//  TodayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol TodayRouter {
    func showTodayEnergyScreen()
}

final class TodayRouterImpl {
    weak var navigationController: UINavigationController? 
    
    
}

extension TodayRouterImpl: TodayRouter {
    func showTodayEnergyScreen() {
        self.navigationController?.pushViewController(TodayEnergyModule.build(), animated: true)
    }
}
