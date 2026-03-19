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
    weak var navigationController: UINavigationController?
    
}

extension ProfileRouterImpl: ProfileRouter {
    func showAddedNewProfiles() {
        self.navigationController?.pushViewController(AddedNewProfilesModule.build(), animated: true)
    }
}
