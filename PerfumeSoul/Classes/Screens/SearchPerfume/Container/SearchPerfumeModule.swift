//
//  SearchPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SearchPerfumeModule {
    @MainActor static func build(requestManager: RequestManager) -> NavigationControllerContainer {
        let viewModel = SearchPerfumeViewModel()
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let navigationController = UINavigationController()
        let router = SearchPerfumeRouterImpl(
            navigationController: navigationController,
            requestManager: requestManager
        )
        let presenter = SearchPerfumePresenterImpl(
            viewModel: viewModel,
            router: router,
            catalogService: CatalogServiceImpl(requestManager: requestManager),
            searchPerfumeService: searchPerfumeService,
            collectionService: PerfumeCollectionServiceImpl(
                storage: PerfumeCollectionStorageImpl(userDefaults: .standard)
            ),
            favoritesStorage: CatalogFavoritesStorage(userDefaults: .standard)
        )

        let imageLoader = PerfumeImageLoader { id in
            let response: CatalogPerfumeImageResponse = try await requestManager.sendRequest(
                request: CatalogPerfumeImageRequest(perfumeID: id)
            )
            return response.imageURL
        }
        let view = SearchPerfumeScreen(viewModel: viewModel, presenter: presenter, imageLoader: imageLoader)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = String(localized: "catalog.title")
        navigationController.setViewControllers([hostingController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true

        return NavigationControllerContainer(navigationController: navigationController)
    }
}
