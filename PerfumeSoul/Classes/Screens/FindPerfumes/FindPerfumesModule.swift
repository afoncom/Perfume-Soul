//
//  FindPerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class FindPerfumesModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = FindPerfumesViewModel()
        let router = FindPerfumesRouterImpl(navigationController: navigationController)
        let presenter = FindPerfumesPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = FindPerfumesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "FindPerfumes"
        
        return hostingController
    }
}
