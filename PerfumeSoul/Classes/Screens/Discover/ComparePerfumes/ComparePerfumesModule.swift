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
        comparePerfumeSelectionService: ComparePerfumeSelectionService,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) -> UIViewController {
        let viewModel = ComparePerfumesViewModel()
        let router = ComparePerfumesRouterImpl(navigationController: navigationController)
        let comparePerfumeService = ComparePerfumeServiceImpl(requestManager: requestManager)
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let presenter = ComparePerfumesPresenterImpl(
            viewModel: viewModel,
            router: router,
            comparePerfumeService: comparePerfumeService,
            searchPerfumeService: searchPerfumeService,
            comparePerfumeSelectionService: comparePerfumeSelectionService
        )
        
        let view = ComparePerfumesScreen(viewModel: viewModel, presenter: presenter, imageLoader: imageLoader)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.comparePerfumes
        hostingController.navigationItem.largeTitleDisplayMode = .never
        
        return hostingController
    }
}
