//
//  ProfileDescriptionRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol ProfileDescriptionRouter {
    func showPersonalPerfume(profileCalculation: ProfileCalculation?)
}

final class ProfileDescriptionRouterImpl {
    private weak var navigationController: UINavigationController?
    private let requestManager: RequestManager
    private let onFinish: (() -> Void)?

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
        self.onFinish = onFinish
    }
}

extension ProfileDescriptionRouterImpl: ProfileDescriptionRouter {
    func showPersonalPerfume(profileCalculation: ProfileCalculation?) {
        let screen = PersonalPerfumeModule.build(
            profileCalculation: profileCalculation,
            requestManager: requestManager,
            onFinish: onFinish
        )
        navigationController?.pushViewController(screen, animated: true)
    }
}
