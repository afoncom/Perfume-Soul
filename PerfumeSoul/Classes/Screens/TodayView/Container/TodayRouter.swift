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
    private let requestManager: RequestManager
    private let imageLoader: PerfumeImageLoader
    private let dailyHoroscopeService: DailyHoroscopeService
    private weak var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader,
        dailyHoroscopeService: DailyHoroscopeService
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
        self.imageLoader = imageLoader
        self.dailyHoroscopeService = dailyHoroscopeService
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
                dailyHoroscopes: dailyHoroscopes,
                dailyHoroscopeService: dailyHoroscopeService
            ),
            animated: true
        )
    }
    
    func showDayInPerfumeryScreen(historyFact: PerfumeHistory) {
        navigationController?.pushViewController(
            DayInPerfumeryModule.build(
                navigationController: navigationController,
                historyFact: historyFact,
                requestManager: requestManager
            ),
            animated: true
        )
    }
}
