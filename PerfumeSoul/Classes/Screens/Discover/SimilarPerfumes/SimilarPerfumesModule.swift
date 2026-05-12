//
//  SimilarPerfumesViewModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SimilarPerfumesModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = SimilarPerfumesViewModel()
        let router = SimilarPerfumesRouterImpl(navigationController: navigationController)
        let presenter = SimilarPerfumesPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = SimilarPerfumesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.similarPerfumes
        
        return hostingController
    }
}
