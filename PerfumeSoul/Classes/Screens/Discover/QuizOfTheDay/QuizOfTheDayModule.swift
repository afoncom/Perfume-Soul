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
        let presenter = QuizOfTheDayPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = QuizOfTheDayScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.quizOfTheDay
        
        return hostingController
    }
}
