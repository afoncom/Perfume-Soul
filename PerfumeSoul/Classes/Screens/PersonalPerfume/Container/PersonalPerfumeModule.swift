//
//  PersonalPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class PersonalPerfumeModule {
    static func build(
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = PersonalPerfumeViewModel()
        let router = PersonalPerfumeRouterImpl(onFinish: onFinish)
        let presenter = PersonalPerfumePresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = PersonalPerfumeScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
