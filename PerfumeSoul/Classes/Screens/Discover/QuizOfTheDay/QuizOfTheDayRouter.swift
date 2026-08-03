//
//  QuizOfTheDayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit
import StoreKit

protocol QuizOfTheDayRouter {
    func requestAppReview()
}

final class QuizOfTheDayRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension QuizOfTheDayRouterImpl: QuizOfTheDayRouter {
    func requestAppReview() {
        guard let windowScene = navigationController?.view.window?.windowScene else {
            return
        }

        SKStoreReviewController.requestReview(in: windowScene)
    }
}
