//
//  PersonalPerfumeRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol PersonalPerfumeRouter {
    func finishOnboarding()
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class PersonalPerfumeRouterImpl {
    private let onFinish: (() -> Void)?
    private weak var navigationController: UINavigationController?

    init(
        navigationController: UINavigationController?,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.onFinish = onFinish
    }
}

extension PersonalPerfumeRouterImpl: PersonalPerfumeRouter {
    func finishOnboarding() {
        onFinish?()
    }

    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(perfume: perfume),
            animated: true
        )
    }
}
