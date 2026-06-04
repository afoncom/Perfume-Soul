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
    private let container: NSPersistentContainer
    
    init(
        navigationController: UINavigationController?,
        container: NSPersistentContainer
    ) {
        self.navigationController = navigationController
        self.container = container
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
            QuizOfTheDayModule.build(
                navigationController: navigationController,
                container: container
            ),
            animated: true
        )
    }
}
