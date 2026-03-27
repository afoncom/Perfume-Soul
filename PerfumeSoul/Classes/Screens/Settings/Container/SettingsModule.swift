//
//  SettingsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SettingsModule {
    static func build() -> UIViewController {
        let viewModel = SettingsViewModel()
        let navigationController = UINavigationController()
        let router = SettingsRouterImpl(navigationController: navigationController)
        let presenter = SettingsPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = SettingsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.settings
        
        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(title: L10n.Screen.settings, image: nil, tag: 3)
        
        return navigationController
    }
}
