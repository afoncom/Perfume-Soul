//
//  QuizOfTheDayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class QuizOfTheDayModule {
    static func build(
        navigationController: UINavigationController?,
        requestManager: RequestManager
    ) -> UIViewController {
        let dayKeyProvider = QuizDayKeyProviderImpl()
        let quizProgressService = QuizProgressServiceImpl(
            userDefaults: .standard,
            dayKeyProvider: dayKeyProvider
        )
        let viewStateStorage = ViewStateStorage<DailyQuizState>(
            userDefaults: .standard,
            storableKey: "quiz.dailyState"
        )
        let viewModel = QuizOfTheDayViewModel()
        let appVersionProvider = AppVersionProviderImpl()
        let appReviewRequester = AppReviewRequesterImpl(
            userDefaults: .standard,
            appVersionProvider: appVersionProvider
        )
        let router = QuizOfTheDayRouterImpl(
            navigationController: navigationController,
            appReviewRequester: appReviewRequester
        )
        let service = QuizOfTheDayServiceImpl(requestManager: requestManager)
        let presenter = QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router,
            service: service,
            dailyQuizStateStorage: viewStateStorage,
            quizProgressService: quizProgressService,
            dayKeyProvider: dayKeyProvider
        )

        let view = QuizOfTheDayScreen(viewModel: viewModel, presenter: presenter)

        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.QuizOfTheDay.title
        hostingController.navigationItem.largeTitleDisplayMode = .always

        return hostingController
    }
}
