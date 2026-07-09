//
//  SettingsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class SettingsModule {
    static func build(
        container: NSPersistentContainer
    ) -> NavigationControllerContainer {
        let profileService = ProfileServiceImpl(container: container)
        let dailyHoroscopeNotificationService = DailyHoroscopeNotificationServiceImpl(
            profileService: profileService
        )
        let viewModel = SettingsViewModel()
        let navigationController = UINavigationController()
        let router = SettingsRouterImpl(navigationController: navigationController)
        let presenter = SettingsPresenterImpl(
            viewModel: viewModel,
            router: router,
            dailyHoroscopeNotificationService: dailyHoroscopeNotificationService
        )
        
        let view = SettingsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.settings
        
        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = true
        
        return NavigationControllerContainer(navigationController: navigationController)
    }
}
