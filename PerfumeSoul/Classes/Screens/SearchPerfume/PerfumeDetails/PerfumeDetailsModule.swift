//
//  PerfumeDetailsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import SwiftUI

final class PerfumeDetailsModule {
    @MainActor static func build(
        perfume: SearchPerfumeItem,
        requestManager: RequestManager
    ) -> UIViewController {
        let viewModel = PerfumeDetailsViewModel(perfume: perfume)
        let router = PerfumeDetailsRouterImpl()
        let perfumeDetailsService = PerfumeDetailsServiceImpl(requestManager: requestManager)
        let presenter = PerfumeDetailsPresenterImpl(
            viewModel: viewModel,
            router: router,
            perfumeDetailsService: perfumeDetailsService,
            collectionService: PerfumeCollectionServiceImpl(
                storage: PerfumeCollectionStorageImpl(
                    userDefaults: .standard
                )
            )
        )

        let view = PerfumeDetailsScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.perfumeDetails

        return hostingController
    }
}
