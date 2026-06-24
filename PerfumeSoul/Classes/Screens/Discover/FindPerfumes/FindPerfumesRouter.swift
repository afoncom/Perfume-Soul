//
//  FindPerfumesRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol FindPerfumesRouter {
    func showPerfumeRecommendationsScreen()
}

final class FindPerfumesRouterImpl {
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

extension FindPerfumesRouterImpl: FindPerfumesRouter {
    func showPerfumeRecommendationsScreen() {
        navigationController?.pushViewController(
            PerfumeRecommendationsModule.build(
                navigationController: navigationController,
                requestManager: requestManager
            ),
            animated: true
        )
    }
}
