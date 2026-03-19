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
        let router = SettingsRouterImpl()
        let presenter = SettingsPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = SettingsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Settings"
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 3)
        router.navigationController = navigationController
        
        return navigationController
    }
}
