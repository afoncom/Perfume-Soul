//
//  QuizOfTheDayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import UIKit

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
        let dailyQuizStateStorage = DailyQuizStateStorageImpl(userDefaults: .standard)
        let viewModel = QuizOfTheDayViewModel()
        let router = QuizOfTheDayRouterImpl(navigationController: navigationController)
        let service = QuizOfTheDayServiceImpl(requestManager: requestManager)
        let presenter = QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router,
            service: service,
            dailyQuizStateStorage: dailyQuizStateStorage,
            quizProgressService: quizProgressService,
            dayKeyProvider: dayKeyProvider
        )

        let view = QuizOfTheDayScreen(viewModel: viewModel, presenter: presenter)

        let hostingController = UIHostingController(rootView: view)
        hostingController.navigationItem.titleView = makeNavigationTitleView()
        hostingController.navigationItem.largeTitleDisplayMode = .never
        hostingController.navigationItem.standardAppearance = makeNavigationBarAppearance()
        hostingController.navigationItem.scrollEdgeAppearance = makeNavigationBarAppearance()

        return hostingController
    }

    private static func makeNavigationTitleView() -> UIView {
        let label = UILabel()
        let descriptor = UIFont.systemFont(ofSize: 24, weight: .bold)
            .fontDescriptor
            .withDesign(.rounded)
        label.font = UIFont(
            descriptor: descriptor ?? UIFont.systemFont(ofSize: 24, weight: .bold).fontDescriptor,
            size: 24
        )
        label.text = L10n.QuizOfTheDay.title
        label.textColor = UIColor(resource: .titleText)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.frame = CGRect(x: 0, y: 0, width: 280, height: 64)

        return label
    }

    private static func makeNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 30, weight: .bold),
            .foregroundColor: UIColor(resource: .titleText)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 21, weight: .semibold),
            .foregroundColor: UIColor(resource: .titleText)
        ]

        return appearance
    }
}
