//
//  PerfumeDetailsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import SwiftUI

final class PerfumeDetailsModule {
    @MainActor static func build(
        navigationController: UINavigationController?,
        perfume: SearchPerfumeItem
    ) -> UIViewController {
        let viewModel = PerfumeDetailsViewModel(perfume: perfume)
        let router = PerfumeDetailsRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let perfumeDetailsService = PerfumeDetailsServiceImpl(requestManager: requestManager)
        let presenter = PerfumeDetailsPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeDetailsService: perfumeDetailsService
        )

        let view = PerfumeDetailsScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.perfumeDetails

        return hostingController
    }
}
