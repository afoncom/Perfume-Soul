//
//  FindPerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import UIKit

final class FindPerfumesModule {
    static func build(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) -> UIViewController {
        let viewModel = FindPerfumesViewModel()
        let router = FindPerfumesRouterImpl(
            navigationController: navigationController,
            requestManager: requestManager,
            imageLoader: imageLoader
        )
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let presenter = FindPerfumesPresenterImpl(
            viewModel: viewModel,
            router: router,
            searchPerfumeService: searchPerfumeService
        )
        
        let view = FindPerfumesScreen(viewModel: viewModel, presenter: presenter, imageLoader: imageLoader)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Discover.FindSimilar.title
        hostingController.navigationItem.largeTitleDisplayMode = .never
        
        return hostingController
    }
}
