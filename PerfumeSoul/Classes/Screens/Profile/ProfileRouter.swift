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
}

final class ProfileRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension ProfileRouterImpl: ProfileRouter {
    func showAddedNewProfiles() {
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(
            AddedNewProfilesModule.build(navigationController: navigationController),
            animated: true
        )
    }
}
