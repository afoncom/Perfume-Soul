//
//  TodayEnergyModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class TodayEnergyModule {
    static func build() -> UIViewController {
        let viewModel = TodayEnergyViewModel()
        let router = TodayEnergyRouterImpl()
        let presenter = TodayEnergyPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = TodayEnergyScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "TodayEnergy"
        
        return hostingController
    }
}
