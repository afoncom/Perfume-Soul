//
//  DiscoverRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol DiscoverRouter {
    func showFindPerfumesScreen()
    func showComparePerfumesScreen()
    func showQuizOfTheDayScreen()
}

final class DiscoverRouterImpl {
    private weak var navigationController: UINavigationController?
    private let comparePerfumeSelectionService: ComparePerfumeSelectionService
    
    init(
        navigationController: UINavigationController?,
        comparePerfumeSelectionService: ComparePerfumeSelectionService
    ) {
        self.navigationController = navigationController
        self.comparePerfumeSelectionService = comparePerfumeSelectionService
    }
}

extension DiscoverRouterImpl: DiscoverRouter {
    func showFindPerfumesScreen() {
        navigationController?.pushViewController(
            FindPerfumesModule.build(navigationController: navigationController),
            animated: true
        )
    }
    
    @MainActor func showComparePerfumesScreen() {
        navigationController?.pushViewController(
            ComparePerfumesModule.build(
                navigationController: navigationController,
                comparePerfumeSelectionService: comparePerfumeSelectionService
            ),
            animated: true
        )
    }
    
    func showQuizOfTheDayScreen() {
        navigationController?.pushViewController(
            QuizOfTheDayModule.build(navigationController: navigationController),
            animated: true
        )
    }
}
