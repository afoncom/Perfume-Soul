//
//  CalculationModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class CalculationModule {
    static func build(
        container: NSPersistentContainer,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = CalculationViewModel()
        let router = CalculationRouterImpl(onFinish: onFinish)
        let profileService = ProfileServiceImpl(container: container)
        let birthPlaceSearch = BirthPlaceSearchService()
        let presenter = CalculationPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService,
            birthPlaceSearch: birthPlaceSearch
        )
        
        let view = CalculationScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
