//
//  PerfumeRecommendationsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class PerfumeRecommendationsModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = PerfumeRecommendationsViewModel()
        let router = PerfumeRecommendationsRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let perfumeRecommendationService = PerfumeRecommendationServiceImpl(requestManager: requestManager)
        let presenter = PerfumeRecommendationsPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeRecommendationService: perfumeRecommendationService
        )
        
        let view = PerfumeRecommendationsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.perfumeRecommendations
        
        return hostingController
    }
}
