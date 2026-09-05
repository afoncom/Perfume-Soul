//
//  DailyPerfumeRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol DailyPerfumeRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class DailyPerfumeRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension DailyPerfumeRouterImpl: DailyPerfumeRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(perfume: perfume),
            animated: true
        )
    }
}
