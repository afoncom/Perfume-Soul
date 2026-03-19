//
//  StartQuizModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class StartQuizModule {
    static func build() -> UIViewController {
        let viewModel = StartQuizViewModel()
        let view = StartQuizScreen(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "StartQuiz"
        
        return hostingController
    }
}
