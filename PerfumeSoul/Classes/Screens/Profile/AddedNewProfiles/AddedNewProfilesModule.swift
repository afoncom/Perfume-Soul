//
//  AddedNewProfilesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class AddedNewProfilesModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let viewModel = AddedNewProfilesViewModel()
        let router = AddedNewProfilesRouterImpl(navigationController: navigationController)
        let presenter = AddedNewProfilesPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = AddedNewProfilesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "AddedNewProfiles"
        
        return hostingController
    }
}
