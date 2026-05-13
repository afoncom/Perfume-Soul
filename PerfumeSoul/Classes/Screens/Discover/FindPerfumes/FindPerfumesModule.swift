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
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let listPerfumeService = ListPerfumeServiceImpl(requestManager: requestManager)
        let presenter = FindPerfumesPresenterImpl(
            viewModel: viewModel,
            router: router,
            listPerfumeService: listPerfumeService
        )
        
        let view = FindPerfumesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.findPerfumes
        
        return hostingController
    }
}
