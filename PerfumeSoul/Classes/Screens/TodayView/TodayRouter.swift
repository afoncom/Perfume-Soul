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
    weak var navigationController: UINavigationController? 
    
    
}

extension TodayRouterImpl: TodayRouter {
    func showTodayEnergyScreen() {
        self.navigationController?.pushViewController(TodayEnergyModule.build(), animated: true)
    }
    
    func showDayInPerfumeryScreen() {
        self.navigationController?.pushViewController(DayInPerfumeryModule.build(), animated: true)
    }
    
    
}
