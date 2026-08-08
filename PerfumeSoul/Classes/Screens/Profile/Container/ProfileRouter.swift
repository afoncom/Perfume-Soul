//
//  ProfileRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit
import CoreData

protocol ProfileRouter {
    func showPersonalPerfumes(profileCalculation: ProfileCalculation?)
    func showProfileDescription()
    func showProfileSetupScreen(profile: Profile)
    func showCalculationScreen()
}

final class ProfileRouterImpl {
    private weak var navigationController: UINavigationController?
    private let container: NSPersistentContainer
    private let requestManager: RequestManager
    private let onProfileSetupRequested: (Profile?) -> Void
    
    init(
        navigationController: UINavigationController?,
        container: NSPersistentContainer,
        requestManager: RequestManager,
        onProfileSetupRequested: @escaping (Profile?) -> Void
    ) {
        self.navigationController = navigationController
        self.container = container
        self.requestManager = requestManager
        self.onProfileSetupRequested = onProfileSetupRequested
    }
}

extension ProfileRouterImpl: ProfileRouter {
    func showPersonalPerfumes(profileCalculation: ProfileCalculation?) {
        let screen = PersonalPerfumeModule.build(
            profileCalculation: profileCalculation,
            requestManager: requestManager
        )
        navigationController?.pushViewController(screen, animated: true)
    }

    func showProfileDescription() {
        let screen = ProfileDescriptionModule.build(
            container: container,
            requestManager: requestManager
        )
        navigationController?.pushViewController(screen, animated: true)
    }

    func showProfileSetupScreen(profile: Profile) {
        onProfileSetupRequested(profile)
    }
    
    func showCalculationScreen() {
        onProfileSetupRequested(nil)
    }
}
