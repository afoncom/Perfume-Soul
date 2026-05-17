//
//  FindPerfumesRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol FindPerfumesRouter {
    func showSimilarPerfumesScreen(similarPerfumes: [SimilarPerfume])
}

final class FindPerfumesRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension FindPerfumesRouterImpl: FindPerfumesRouter {
    func showSimilarPerfumesScreen(similarPerfumes: [SimilarPerfume]) {
        navigationController?.pushViewController(
            SimilarPerfumesModule.build(
                navigationController: navigationController,
                similarPerfumes: similarPerfumes
            ),
            animated: true
        )
    }
}
