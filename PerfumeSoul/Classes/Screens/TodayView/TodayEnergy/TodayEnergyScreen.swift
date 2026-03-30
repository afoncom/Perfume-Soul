//
//  TodayEnergyScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct TodayEnergyScreen: View {
    @Bindable private var viewModel: TodayEnergyViewModel
    private let presenter: TodayEnergyPresenter
    
    init(
        viewModel: TodayEnergyViewModel,
        presenter: TodayEnergyPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text(L10n.Screen.todayEnergy)
    }
}

extension TodayEnergyScreen {
    
}
