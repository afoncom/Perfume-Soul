//
//  SimilarPerfumesRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol SimilarPerfumesRouter {
    
}

final class SimilarPerfumesRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension SimilarPerfumesRouterImpl: SimilarPerfumesRouter {
    
}
