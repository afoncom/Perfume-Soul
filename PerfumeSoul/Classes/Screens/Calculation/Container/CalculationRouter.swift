//
//  CalculationRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit
import CoreData

protocol CalculationRouter {
    func showProfileDescription()
}

final class CalculationRouterImpl {
    private weak var navigationController: UINavigationController?
    private let container: NSPersistentContainer
    private let requestManager: RequestManager
    private let onFinish: () -> Void

    init(
        navigationController: UINavigationController?,
        container: NSPersistentContainer,
        requestManager: RequestManager,
        onFinish: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.container = container
        self.requestManager = requestManager
        self.onFinish = onFinish
    }
}

extension CalculationRouterImpl: CalculationRouter {
    func showProfileDescription() {
        let screen = ProfileDescriptionModule.build(
            container: container,
            requestManager: requestManager,
            navigationController: navigationController,
            onFinish: onFinish
        )
        navigationController?.pushViewController(screen, animated: true)
    }
}
