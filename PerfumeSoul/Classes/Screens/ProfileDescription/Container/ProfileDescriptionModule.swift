//
//  ProfileDescriptionModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData
import UIKit

final class ProfileDescriptionModule {
    static func build(
        container: NSPersistentContainer,
        requestManager: RequestManager,
        navigationController: UINavigationController? = nil,
        onFinish: (() -> Void)? = nil
    ) -> UIViewController {
        let viewModel = ProfileDescriptionViewModel()
        let router = ProfileDescriptionRouterImpl(
            navigationController: navigationController,
            onFinish: onFinish
        )
        let profileService = ProfileServiceImpl(container: container)
        let profileCalculationService = ProfileCalculationServiceImpl(requestManager: requestManager)
        let profileDescriptionBuilder = ProfileDescriptionBuilderImpl()
        let presenter = ProfileDescriptionPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService,
            profileCalculationService: profileCalculationService,
            profileDescriptionBuilder: profileDescriptionBuilder,
            shouldShowContinueButton: onFinish != nil
        )
        
        let view = ProfileDescriptionScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        return hostingController
    }
}
