//
//  TodayEnergyModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class TodayEnergyModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = TodayEnergyViewModel()
        let router = TodayEnergyRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let dailyHoroscopeService = DailyHoroscopeServiceImpl(requestManager: requestManager)
        let presenter = TodayEnergyPresenterImpl(
            viewModel: viewModel,
            router: router,
            dailyHoroscopeService: dailyHoroscopeService
        )
        
        let view = TodayEnergyScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.todayEnergy
        
        return hostingController
    }
}
