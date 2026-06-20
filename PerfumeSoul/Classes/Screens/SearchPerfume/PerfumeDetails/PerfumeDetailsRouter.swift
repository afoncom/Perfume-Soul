//
//  PerfumeDetailsRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import UIKit

protocol PerfumeDetailsRouter {
    
}

final class PerfumeDetailsRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension PerfumeDetailsRouterImpl: PerfumeDetailsRouter {
    
}
