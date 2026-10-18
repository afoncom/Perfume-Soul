//
//  DiscoverRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit
import CoreData

protocol DiscoverRouter {
    func showFindPerfumesScreen()
    func showComparePerfumesScreen()
    func showQuizOfTheDayScreen()
}

final class DiscoverRouterImpl {
    private weak var navigationController: UINavigationController?
    private let comparePerfumeSelectionService: ComparePerfumeSelectionService
    private let container: NSPersistentContainer
    private let requestManager: RequestManager
    
    init(
        navigationController: UINavigationController?,
        comparePerfumeSelectionService: ComparePerfumeSelectionService,
        container: NSPersistentContainer,
        requestManager: RequestManager
    ) {
        self.navigationController = navigationController
        self.comparePerfumeSelectionService = comparePerfumeSelectionService
        self.container = container
        self.requestManager = requestManager
    }
}

extension DiscoverRouterImpl: DiscoverRouter {
    func showFindPerfumesScreen() {
        navigationController?.pushViewController(
            FindPerfumesModule.build(
                navigationController: navigationController,
                requestManager: requestManager
            ),
            animated: true
        )
    }
    
    @MainActor func showComparePerfumesScreen() {
        navigationController?.pushViewController(
            ComparePerfumesModule.build(
                navigationController: navigationController,
                comparePerfumeSelectionService: comparePerfumeSelectionService,
                requestManager: requestManager
            ),
            animated: true
        )
    }
    
    func showQuizOfTheDayScreen() {
        navigationController?.pushViewController(
            QuizOfTheDayModule.build(
                navigationController: navigationController,
                container: container,
                requestManager: requestManager
            ),
            animated: true
        )
    }
}
