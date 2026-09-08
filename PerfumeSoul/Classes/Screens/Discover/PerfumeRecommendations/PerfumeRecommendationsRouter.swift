//
//  PerfumeRecommendationsRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol PerfumeRecommendationsRouter {
    @MainActor
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class PerfumeRecommendationsRouterImpl {
    private weak var navigationController: UINavigationController?
    private let requestManager: RequestManager

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
    }
}

extension PerfumeRecommendationsRouterImpl: PerfumeRecommendationsRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(
                perfume: perfume,
                requestManager: requestManager
            ),
            animated: true
        )
    }
}
