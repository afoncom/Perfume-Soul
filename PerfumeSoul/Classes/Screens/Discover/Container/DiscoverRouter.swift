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
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension DiscoverRouterImpl: DiscoverRouter {
    func showFindPerfumesScreen() {
        navigationController?.pushViewController(
            FindPerfumesModule.build(navigationController: navigationController),
            animated: true
        )
    }
    
    func showComparePerfumesScreen() {
        navigationController?.pushViewController(
            ComparePerfumesModule.build(navigationController: navigationController),
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
