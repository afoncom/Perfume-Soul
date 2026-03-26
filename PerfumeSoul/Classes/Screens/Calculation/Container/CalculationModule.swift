//
//  CalculationModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class CalculationModule {
    static func build(onFinish: @escaping () -> Void) -> UIViewController {
        let viewModel = CalculationViewModel()
        let router = CalculationRouterImpl(onFinish: onFinish)
        let presenter = CalculationPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = CalculationScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
