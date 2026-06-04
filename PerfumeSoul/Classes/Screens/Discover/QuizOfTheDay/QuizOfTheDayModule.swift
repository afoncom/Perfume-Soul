//
//  QuizOfTheDayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class QuizOfTheDayModule {
    static func build(
        navigationController: UINavigationController?,
        container: NSPersistentContainer
    ) -> UIViewController {
        let profileService = ProfileServiceImpl(container: container)
        let progressStorage = QuizOfTheDayProgressStorageImpl(userDefaults: .standard)
        let viewModel = QuizOfTheDayViewModel(
            progress: progressStorage.loadProgress(),
            onCorrectAnswer: {
                Task {
                    await profileService.incrementTotalCorrectQuizAnswers()
                }
            },
            onQuizCompletion: {
                progressStorage.completeQuiz()
            },
            onProgressChange: { progress in
                progressStorage.saveProgress(progress)
            }
        )
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
