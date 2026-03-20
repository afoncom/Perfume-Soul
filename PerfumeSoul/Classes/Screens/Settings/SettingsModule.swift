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
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Settings"
        
        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 3)
        
        return navigationController
    }
}
