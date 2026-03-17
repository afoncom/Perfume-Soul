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
        let view = TodayEnergyScreen()
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "TodayEnergy"
        
        return hostingController
    }
}
