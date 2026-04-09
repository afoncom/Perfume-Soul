//
//  ProfileRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol ProfileRouter {
    func showAddedNewProfiles()
    func showCalculationScreen()
}

final class ProfileRouterImpl {
    private weak var navigationController: UINavigationController?
    private let onProfileDeleted: () -> Void
    
    init(
        navigationController: UINavigationController?,
        onProfileDeleted: @escaping () -> Void
    ) {
        self.navigationController = navigationController
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
    
    func showCalculationScreen() {
        onProfileDeleted()
    }
}
