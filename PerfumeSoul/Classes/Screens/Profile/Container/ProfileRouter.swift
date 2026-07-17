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
    func showAddedNewProfiles()
    func showPersonalPerfumes()
    func showProfileDescription()
    func showCalculationScreen()
}

final class ProfileRouterImpl {
    private weak var navigationController: UINavigationController?
    private let container: NSPersistentContainer
    private let onProfileDeleted: () -> Void
    
    init(
        navigationController: UINavigationController?,
        container: NSPersistentContainer,
        onProfileDeleted: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.container = container
        self.onProfileDeleted = onProfileDeleted
    }
}

extension ProfileRouterImpl: ProfileRouter {
    func showAddedNewProfiles() {
        navigationController?.pushViewController(
            AddedNewProfilesModule.build(navigationController: navigationController),
            animated: true
        )
    }
    
    func showPersonalPerfumes() {
        let screen = PersonalPerfumeModule.build()
        navigationController?.pushViewController(screen, animated: true)
    }

    func showProfileDescription() {
        let screen = ProfileDescriptionModule.build(
            container: container
        )
        navigationController?.pushViewController(screen, animated: true)
    }
    
    func showCalculationScreen() {
        onProfileDeleted()
    }
}
