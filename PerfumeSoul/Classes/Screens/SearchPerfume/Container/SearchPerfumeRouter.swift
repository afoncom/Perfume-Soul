//
//  SearchPerfumeRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol SearchPerfumeRouter {
    @MainActor
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class SearchPerfumeRouterImpl {
    private weak var navigationController: UINavigationController?
    private let imageLoader: PerfumeImageLoader
    private let requestManager: RequestManager

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
        self.imageLoader = imageLoader
    }
}

extension SearchPerfumeRouterImpl: SearchPerfumeRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(
                perfume: perfume,
                requestManager: requestManager,
                imageLoader: imageLoader
            ),
            animated: true
        )
    }
}
