//
//  PerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct PerfumeScreen: View {
    @Bindable private var viewModel: PerfumeViewModel
    private let presenter: PerfumePresenter
    
    init(
        viewModel: PerfumeViewModel,
        presenter: PerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("MainScreen")
    }
}

extension PerfumeScreen {
    
}
