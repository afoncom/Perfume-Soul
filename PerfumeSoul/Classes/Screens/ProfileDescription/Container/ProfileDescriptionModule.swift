//
//  ProfileDescriptionModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class ProfileDescriptionModule {
    static func build(container: NSPersistentContainer) -> UIViewController {
        let viewModel = ProfileDescriptionViewModel()
        let router = ProfileDescriptionRouterImpl()
        let profileService = ProfileServiceImpl(container: container)
        let presenter = ProfileDescriptionPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService
        )
        
        let view = ProfileDescriptionScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
