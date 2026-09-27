//
//  CalculationLoadingRouter.swift
//  PerfumeSoul
//

import UIKit
import CoreData

@MainActor
protocol CalculationLoadingRouter {
    func showProfileDescription()
    func showCalculationScreen()
}

final class CalculationLoadingRouterImpl {
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

extension CalculationLoadingRouterImpl: CalculationLoadingRouter {
    func showProfileDescription() {
        guard let navigationController, let calculationScreen = navigationController.viewControllers.first else {
            return
        }

        let screen = ProfileDescriptionModule.build(
            container: container,
            requestManager: requestManager,
            navigationController: navigationController,
            onFinish: onFinish
        )
        
        navigationController.setViewControllers([calculationScreen, screen], animated: true)
    }

    func showCalculationScreen() {
        navigationController?.popViewController(animated: true)
    }
}
