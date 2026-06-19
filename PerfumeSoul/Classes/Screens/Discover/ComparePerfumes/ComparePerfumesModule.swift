//
//  ComparePerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class ComparePerfumesModule {
    @MainActor static func build(
        navigationController: UINavigationController?,
        comparePerfumeSelectionService: ComparePerfumeSelectionService
    ) -> UIViewController {
        let viewModel = ComparePerfumesViewModel()
        let router = ComparePerfumesRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let comparePerfumeService = ComparePerfumeServiceImpl(requestManager: requestManager)
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let presenter = ComparePerfumesPresenterImpl(
            viewModel: viewModel,
            router: router,
            comparePerfumeService: comparePerfumeService,
            searchPerfumeService: searchPerfumeService,
            comparePerfumeSelectionService: comparePerfumeSelectionService
        )
        
        let view = ComparePerfumesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.comparePerfumes
        
        return hostingController
    }
}
