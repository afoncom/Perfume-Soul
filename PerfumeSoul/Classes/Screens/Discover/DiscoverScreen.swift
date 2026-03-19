//
//  DiscoverScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DiscoverScreen: View {
    @Bindable private var viewModel: DiscoverViewModel
    private let presenter: DiscoverPresenter
    
    init(
        viewModel: DiscoverViewModel,
        presenter: DiscoverPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("Discover")
        
        Button("ComparePerfumes") {
            presenter.comparePerfumesButtonTab()
        }
        
        Button("StartQuiz") {
            presenter.startQuizButtonTab()
        }
    }
}

extension DiscoverScreen {
    
}

