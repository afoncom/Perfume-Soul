//
//  DiscoverModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class DiscoverModule {
    static func build(container: NSPersistentContainer) -> UIViewController {
        let viewModel = DiscoverViewModel()
        let navigationController = UINavigationController()
        let router = DiscoverRouterImpl(
            navigationController: navigationController,
            container: container
        )
        let presenter = DiscoverPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = DiscoverScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.discover
        
        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.Screen.discover,
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        navigationController.navigationBar.prefersLargeTitles = true

        return navigationController
    }
}
