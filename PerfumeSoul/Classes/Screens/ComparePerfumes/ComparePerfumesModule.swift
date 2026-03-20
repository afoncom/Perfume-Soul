//
//  ComparePerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class ComparePerfumesModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = ComparePerfumesViewModel()
        let router = ComparePerfumesRouterImpl(navigationController: navigationController)
        let presenter = ComparePerfumesPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = ComparePerfumesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "ComparePerfumes"
        
        return hostingController
    }
}
