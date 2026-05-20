//
//  QuizOfTheDayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol QuizOfTheDayRouter {
    
}

final class QuizOfTheDayRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension QuizOfTheDayRouterImpl: QuizOfTheDayRouter {
    
}
