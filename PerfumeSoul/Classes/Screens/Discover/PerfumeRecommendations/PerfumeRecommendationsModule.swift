//
//  PerfumeRecommendationsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import UIKit

final class PerfumeRecommendationsModule {
    static func build(
        navigationController: UINavigationController?,
        selectedPerfumes: [SearchPerfumeItem],
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) -> UIViewController {
        let viewModel = PerfumeRecommendationsViewModel(selectedPerfumes: selectedPerfumes)
        let router = PerfumeRecommendationsRouterImpl(
            navigationController: navigationController,
            requestManager: requestManager,
            imageLoader: imageLoader
        )
        let perfumeRecommendationService = PerfumeRecommendationServiceImpl(requestManager: requestManager)
        let presenter = PerfumeRecommendationsPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeRecommendationService: perfumeRecommendationService
        )
        
        let view = PerfumeRecommendationsScreen(viewModel: viewModel, presenter: presenter, imageLoader: imageLoader)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Discover.FindSimilar.resultsTitle
        hostingController.navigationItem.largeTitleDisplayMode = .never
        
        return hostingController
    }
}
