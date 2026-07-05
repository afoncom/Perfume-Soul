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
        requestManager: RequestManager
    ) -> UIViewController {
        let viewModel = PerfumeRecommendationsViewModel(selectedPerfumes: selectedPerfumes)
        let router = PerfumeRecommendationsRouterImpl(navigationController: navigationController)
        let perfumeRecommendationService = PerfumeRecommendationServiceImpl(requestManager: requestManager)
        let perfumeDetailsService = PerfumeDetailsServiceImpl(requestManager: requestManager)
        let presenter = PerfumeRecommendationsPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeRecommendationService: perfumeRecommendationService,
            perfumeDetailsService: perfumeDetailsService
        )
        
        let view = PerfumeRecommendationsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.perfumeRecommendations
        
        return hostingController
    }
}
