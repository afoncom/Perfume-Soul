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
    @MainActor func showCalculationLoading()
}

final class CalculationRouterImpl {
    private weak var navigationController: UINavigationController?
    private let container: NSPersistentContainer
    private let requestManager: RequestManager
    private let imageLoader: PerfumeImageLoader
    private let onFinish: () -> Void

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

extension CalculationRouterImpl: CalculationRouter {
    func showCalculationLoading() {
        let screen = CalculationLoadingModule.build(
            container: container,
            requestManager: requestManager,
            imageLoader: imageLoader,
            navigationController: navigationController,
            onFinish: onFinish
        )
        navigationController?.pushViewController(screen, animated: true)
    }
}
