//
//  TodayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI
import CoreData

final class TodayModule {
    static func build(
        container: NSPersistentContainer,
        requestManager: RequestManager
    ) -> NavigationControllerContainer {
        let viewModel = TodayViewModel()
        let navigationController = UINavigationController()
        let router = TodayRouterImpl(navigationController: navigationController)
        let perfumeHistoryService = PerfumeHistoryServiceImpl(requestManager: requestManager)
        let dailyHoroscopeService = DailyHoroscopeServiceImpl(requestManager: requestManager)
        let profileService = ProfileServiceImpl(container: container)
        let presenter = TodayPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeHistoryService: perfumeHistoryService,
            dailyHoroscopeService: dailyHoroscopeService,
            profileService: profileService
        )
        
        let view = TodayScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.today

        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = true
        
        return NavigationControllerContainer(navigationController: navigationController)
    }
}
