//
//  TodayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol TodayRouter {
    func showTodayEnergyScreen(
        personalDailyHoroscope: DailyHoroscope,
        dailyHoroscopes: [DailyHoroscope]
    )
    func showDayInPerfumeryScreen(historyFact: PerfumeHistory)
}

final class TodayRouterImpl {
    private let imageLoader: PerfumeImageLoader
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?, imageLoader: PerfumeImageLoader) {
        self.navigationController = navigationController
        self.imageLoader = imageLoader
    }
}

extension TodayRouterImpl: TodayRouter {
    func showTodayEnergyScreen(
        personalDailyHoroscope: DailyHoroscope,
        dailyHoroscopes: [DailyHoroscope]
    ) {
        navigationController?.pushViewController(
            TodayEnergyModule.build(
                navigationController: navigationController,
                personalDailyHoroscope: personalDailyHoroscope,
                dailyHoroscopes: dailyHoroscopes
            ),
            animated: true
        )
    }
    
    func showDayInPerfumeryScreen(historyFact: PerfumeHistory) {
        navigationController?.pushViewController(
            DayInPerfumeryModule.build(
                navigationController: navigationController,
                historyFact: historyFact,
                imageLoader: imageLoader
            ),
            animated: true
        )
    }
}
