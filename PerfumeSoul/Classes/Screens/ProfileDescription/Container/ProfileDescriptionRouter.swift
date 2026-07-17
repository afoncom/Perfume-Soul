//
//  ProfileDescriptionRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol ProfileDescriptionRouter {
    func showPersonalPerfume()
}

final class ProfileDescriptionRouterImpl {
    private weak var navigationController: UINavigationController?
    private let onFinish: (() -> Void)?

    init(
        navigationController: UINavigationController?,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.onFinish = onFinish
    }
}

extension ProfileDescriptionRouterImpl: ProfileDescriptionRouter {
    func showPersonalPerfume() {
        let screen = PersonalPerfumeModule.build(onFinish: onFinish)
        navigationController?.pushViewController(screen, animated: true)
    }
}
