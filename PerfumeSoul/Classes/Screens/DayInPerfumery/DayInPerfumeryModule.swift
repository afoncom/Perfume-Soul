//
//  TodayEnergyModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class DayInPerfumeryModule {
    static func build() -> UIViewController {
        let viewModel = DayInPerfumeryViewModel()
        let view = DayInPerfumeryScreen(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "DayInPerfumery"
        
        return hostingController
    }
}
