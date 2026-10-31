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
    static func build(
        container: NSPersistentContainer,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) -> NavigationControllerContainer {
        let viewModel = DiscoverViewModel()
        let navigationController = UINavigationController()
        let comparePerfumeSelectionService = ComparePerfumeSelectionServiceImpl()
        let router = DiscoverRouterImpl(
            navigationController: navigationController,
            comparePerfumeSelectionService: comparePerfumeSelectionService,
            container: container,
            requestManager: requestManager,
            imageLoader: imageLoader
        )
        let presenter = DiscoverPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = DiscoverScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.discover
        hostingController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = false

        return NavigationControllerContainer(navigationController: navigationController)
    }
}
