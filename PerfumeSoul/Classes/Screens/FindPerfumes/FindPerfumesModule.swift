//
//  FindPerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class FindPerfumesModule {
    static func build() -> UIViewController {
        let viewModel = FindPerfumesViewModel()
        let view = FindPerfumesScreen(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "TodayEnergy"
        
        return hostingController
    }
}
