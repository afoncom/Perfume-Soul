//
//  StartQuizScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct StartQuizScreen: View {
    @Bindable private var viewModel: StartQuizViewModel
    private let presenter: StartQuizPresenter
    
    init(
        viewModel: StartQuizViewModel,
        presenter: StartQuizPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("StartQuiz")
    }
}

extension StartQuizScreen {
    
}
