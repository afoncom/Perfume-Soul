//
//  TodayEnergyModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class DayInPerfumeryModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = DayInPerfumeryViewModel()
        let router = DayInPerfumeryRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let perfumeHistoryService = PerfumeHistoryServiceImpl(requestManager: requestManager)
        let presenter = DayInPerfumeryPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeHistoryService: perfumeHistoryService
        )
        
        let view = DayInPerfumeryScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.dayInPerfumery
        
        return hostingController
    }
}
