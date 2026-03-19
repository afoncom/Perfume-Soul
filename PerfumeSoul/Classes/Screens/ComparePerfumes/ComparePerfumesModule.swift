//
//  ComparePerfumesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class ComparePerfumesModule {
    static func build() -> UIViewController {
        let viewModel = ComparePerfumesViewModel()
        let view = ComparePerfumesScreen(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "ComparePerfumes"
        
        return hostingController
    }
}
