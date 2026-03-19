//
//  ComparePerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ComparePerfumesScreen: View {
    @Bindable var viewModel: ComparePerfumesViewModel
    private let presenter: ComparePerfumesPresenter
    
    init(
        viewModel: ComparePerfumesViewModel,
        presenter: ComparePerfumesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("ComparePerfumes")
    }
}

extension ComparePerfumesScreen {
    
}
