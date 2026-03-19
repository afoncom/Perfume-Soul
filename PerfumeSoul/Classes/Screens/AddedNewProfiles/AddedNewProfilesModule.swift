//
//  AddedNewProfilesModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class AddedNewProfilesModule {
    static func build() -> UIViewController {
        let viewModel = AddedNewProfilesViewModel()
        let router = AddedNewProfilesRouterImpl()
        let presenter = AddedNewProfilesPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = AddedNewProfilesScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "AddedNewProfiles"
        
        return hostingController
    }
}
