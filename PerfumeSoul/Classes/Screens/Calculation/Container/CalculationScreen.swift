//
//  CalculationScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct CalculationScreen: View {
    @Bindable private var viewModel: CalculationViewModel
    private let presenter: CalculationPresenter
    
    init(
        viewModel: CalculationViewModel,
        presenter: CalculationPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("CalculationScreen")
    }
}
