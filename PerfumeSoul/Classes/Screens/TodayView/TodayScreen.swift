//
//  TodayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct TodayScreen: View {
    @Bindable private var viewModel: TodayViewModel
    private let presenter: TodayPresenter
    
    init(
        viewModel: TodayViewModel,
        presenter: TodayPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("Today")
        
        Button(action: {
            presenter.todayEnergyButtonTab()
        }
        ) {
            Text("TodayEnergy")
        }
    }
}

extension TodayScreen {
    
}
