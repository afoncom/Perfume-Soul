//
//  QuizOfTheDayRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol QuizOfTheDayRouter {
    @MainActor
    func requestAppReview()
}

final class QuizOfTheDayRouterImpl {
    private weak var navigationController: UINavigationController?
    private let appReviewRequester: AppReviewRequester

    init(
        navigationController: UINavigationController?,
        appReviewRequester: AppReviewRequester = AppReviewRequester()
    ) {
        self.navigationController = navigationController
        self.appReviewRequester = appReviewRequester
    }
}

extension QuizOfTheDayRouterImpl: QuizOfTheDayRouter {
    @MainActor
    func requestAppReview() {
        guard let windowScene = navigationController?.view.window?.windowScene else {
            return
        }

        appReviewRequester.requestReviewAfterQuizCompletion(in: windowScene)
    }
}
