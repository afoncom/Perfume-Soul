//
//  QuizOfTheDayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class QuizOfTheDayModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = QuizOfTheDayViewModel()
        let router = QuizOfTheDayRouterImpl(navigationController: navigationController)
        let requestManager = RequestManagerImpl(urlSession: URLSession.shared, baseURL: "http://127.0.0.1:8080")
        let service = QuizOfTheDayServiceImpl(requestManager: requestManager)
        let presenter = QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router,
            service: service
        )

        let view = QuizOfTheDayScreen(viewModel: viewModel, presenter: presenter)

        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.quizOfTheDay

        return hostingController
    }
}
