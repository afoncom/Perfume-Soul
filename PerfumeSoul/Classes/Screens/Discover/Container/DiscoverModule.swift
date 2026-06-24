//
//  DiscoverModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class DiscoverModule {
    static func build() -> NavigationControllerWrapper {
        let viewModel = DiscoverViewModel()
        let navigationController = UINavigationController()
        let comparePerfumeSelectionService = ComparePerfumeSelectionServiceImpl()
        let router = DiscoverRouterImpl(
            navigationController: navigationController,
            comparePerfumeSelectionService: comparePerfumeSelectionService
        )
        let presenter = DiscoverPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = DiscoverScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.discover
        
        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = true

        return NavigationControllerWrapper(navigationController: navigationController)
    }
}
