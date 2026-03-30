//
//  ProfileModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class ProfileModule {
    static func build() -> UIViewController {
        let viewModel = ProfileViewMoodel()
        let navigationController = UINavigationController()
        let router = ProfileRouterImpl(navigationController: navigationController)
        let presenter = ProfilePresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = ProfileScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.profile
        
        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(title: L10n.Screen.profile, image: nil, tag: 2)
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
}
