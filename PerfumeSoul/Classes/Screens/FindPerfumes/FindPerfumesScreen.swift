//
//  FindPerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct FindPerfumesScreen: View {
    @Bindable private var viewModel: FindPerfumesViewModel
    private let presenter: FindPerfumesPresenter
    
    init(
        viewModel: FindPerfumesViewModel,
        presenter: FindPerfumesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("FindPerfumes")
    }
}

extension FindPerfumesScreen {
    
}
