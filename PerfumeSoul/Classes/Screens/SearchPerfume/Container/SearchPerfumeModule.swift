//
//  SearchPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SearchPerfumeModule {
    static func build(requestManager: RequestManager) -> UIViewController {
        let viewModel = SearchPerfumeViewModel()
        let navigationController = UINavigationController()
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let router = SearchPerfumeRouterImpl()
        let presenter = SearchPerfumePresenterImpl(
            viewModel: viewModel,
            router: router,
            searchPerfumeService: searchPerfumeService
        )
        
        let view = SearchPerfumeScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.searchPerfume

        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.Screen.searchPerfume,
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        navigationController.navigationBar.prefersLargeTitles = true

        return navigationController
    }
}
