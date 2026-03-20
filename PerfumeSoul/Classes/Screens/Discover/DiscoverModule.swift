//
//  DiscoverModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class DiscoverModule {
    static func build() -> UIViewController {
        let viewModel = DiscoverViewModel()
        let navigationController = UINavigationController()
        let router = DiscoverRouterImpl(navigationController: navigationController)
        let presenter = DiscoverPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = DiscoverScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Discover"
        
        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(title: "Discover", image: nil, tag: 1)

        return navigationController
    }
}
