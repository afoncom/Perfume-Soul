//
//  PerfumeRecommendationsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class PerfumeRecommendationsModule {
    static func build(
        navigationController: UINavigationController?,
        perfumeRecommendations: [PerfumeRecommendation]
    ) -> UIViewController {
        let viewModel = PerfumeRecommendationsViewModel(perfumeRecommendations: perfumeRecommendations)
        let router = PerfumeRecommendationsRouterImpl(navigationController: navigationController)
        let presenter = PerfumeRecommendationsPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = PerfumeRecommendationsScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.perfumeRecommendations
        
        return hostingController
    }
}
