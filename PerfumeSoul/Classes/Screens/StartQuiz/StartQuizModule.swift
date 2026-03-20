//
//  StartQuizModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class StartQuizModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = StartQuizViewModel()
        let router = StartQuizRouterImpl(navigationController: navigationController)
        let presenter = StartQuizPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = StartQuizScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "StartQuiz"
        
        return hostingController
    }
}
