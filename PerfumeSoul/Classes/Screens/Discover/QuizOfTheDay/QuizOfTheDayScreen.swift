//
//  QuizOfTheDayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct QuizOfTheDayScreen: View {
    @Bindable private var viewModel: QuizOfTheDayViewModel
    private let presenter: QuizOfTheDayPresenter
    
    init(
        viewModel: QuizOfTheDayViewModel,
        presenter: QuizOfTheDayPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text(L10n.Screen.quizOfTheDay)
    }
}

extension QuizOfTheDayScreen {
    
}
