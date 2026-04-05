//
//  WelcomeLoadingModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class WelcomeLoadingModule {
    static func build(
        container: NSPersistentContainer,
        onProfileExists: @escaping () -> Void,
        onProfileMissing: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = WelcomeLoadingViewModel()
        let profileService = ProfileServiceImpl(container: container)
        let router = WelcomeLoadingRouterImpl(
            onProfileExists: onProfileExists,
            onProfileMissing: onProfileMissing
        )
        let presenter = WelcomeLoadingPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService
        )
        
        let view = WelcomeLoadingScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
