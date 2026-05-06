//
//  TodayEnergyModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class TodayEnergyModule {
    static func build(
        navigationController: UINavigationController?,
        personalDailyHoroscope: DailyHoroscopeResponse?,
        dailyHoroscopes: [DailyHoroscopeResponse]
    ) -> UIViewController {
        let viewModel = TodayEnergyViewModel()
        viewModel.personalDailyHoroscope = personalDailyHoroscope
        viewModel.dailyHoroscopes = dailyHoroscopes
        let router = TodayEnergyRouterImpl(navigationController: navigationController)
        let presenter = TodayEnergyPresenterImpl(viewModel: viewModel, router: router)
        
        let view = TodayEnergyScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.todayEnergy
        
        return hostingController
    }
}
