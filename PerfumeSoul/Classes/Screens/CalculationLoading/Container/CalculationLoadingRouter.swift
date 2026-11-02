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
    func setBackNavigationEnabled(_ isEnabled: Bool)
}

final class CalculationLoadingRouterImpl {
    private weak var navigationController: UINavigationController?
    private let container: NSPersistentContainer
    private let requestManager: RequestManager
    private let imageLoader: PerfumeImageLoader
    private let onFinish: () -> Void
    private var previousInteractivePopEnabled = false
    private var isBackNavigationLocked = false

    init(
        navigationController: UINavigationController?,
        container: NSPersistentContainer,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader,
        onFinish: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.container = container
        self.requestManager = requestManager
        self.imageLoader = imageLoader
        self.onFinish = onFinish
    }
}

extension CalculationLoadingRouterImpl: CalculationLoadingRouter {
    func setBackNavigationEnabled(_ isEnabled: Bool) {
        guard let gesture = navigationController?.interactivePopGestureRecognizer else {
            return
        }

        if isEnabled {
            if isBackNavigationLocked {
                gesture.isEnabled = previousInteractivePopEnabled
                isBackNavigationLocked = false
            }
        } else {
            if !isBackNavigationLocked {
                previousInteractivePopEnabled = gesture.isEnabled
                isBackNavigationLocked = true
            }
            gesture.isEnabled = false
        }
    }

    func showProfileDescription() {
        guard let navigationController, let calculationScreen = navigationController.viewControllers.first else {
            return
        }

        let screen = ProfileDescriptionModule.build(
            container: container,
            requestManager: requestManager,
            imageLoader: imageLoader,
            navigationController: navigationController,
            onFinish: onFinish
        )
        
        navigationController.setViewControllers([calculationScreen, screen], animated: true)
    }

    func showCalculationScreen() {
        navigationController?.popViewController(animated: true)
    }
}
