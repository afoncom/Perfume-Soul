//
//  FindPerfumesRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol FindPerfumesRouter {
    func showPerfumeRecommendationsScreen(selectedPerfumes: [SearchPerfumeItem])
}

final class FindPerfumesRouterImpl {
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

extension FindPerfumesRouterImpl: FindPerfumesRouter {
    func showPerfumeRecommendationsScreen(selectedPerfumes: [SearchPerfumeItem]) {
        navigationController?.pushViewController(
            PerfumeRecommendationsModule.build(
                navigationController: navigationController,
                selectedPerfumes: selectedPerfumes,
                requestManager: requestManager,
                imageLoader: imageLoader
            ),
            animated: true
        )
    }
}
