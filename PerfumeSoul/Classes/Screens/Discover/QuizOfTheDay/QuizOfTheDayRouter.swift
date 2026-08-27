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
    func registerQuizCompletion(for quizDayKey: String)
    @MainActor
    func requestAppReviewIfEligible()
}

final class QuizOfTheDayRouterImpl {
    private weak var navigationController: UINavigationController?
    private let appReviewRequester: AppReviewRequester

    init(
        navigationController: UINavigationController?,
        appReviewRequester: AppReviewRequester
    ) {
        self.navigationController = navigationController
        self.appReviewRequester = appReviewRequester
    }
}

extension QuizOfTheDayRouterImpl: QuizOfTheDayRouter {
    @MainActor
    func registerQuizCompletion(for quizDayKey: String) {
        appReviewRequester.registerQuizCompletion(for: quizDayKey)
    }

    @MainActor
    func requestAppReviewIfEligible() {
        guard let windowScene = navigationController?.view.window?.windowScene else {
            return
        }

        appReviewRequester.requestReviewIfEligible(in: windowScene)
    }
}
