//
//  DiscoverRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol DiscoverRouter {
    func showComparePerfumesScreen()
    func showStartQuizScreen()
}

final class DiscoverRouterImpl {
    weak var navigationController: UINavigationController?

}

extension DiscoverRouterImpl: DiscoverRouter {
    func showComparePerfumesScreen() {
        self.navigationController?.pushViewController(ComparePerfumesModule.build(), animated: true)
    func showStartQuizScreen() {
        self.navigationController?.pushViewController(StartQuizModule.build(), animated: true)
    }
}
