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
    func finishOnboarding()
}

final class ProfileDescriptionRouterImpl {
    private weak var navigationController: UINavigationController?
    private let imageLoader: PerfumeImageLoader
    private let requestManager: RequestManager
    private let onFinish: (() -> Void)?

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
        self.imageLoader = imageLoader
        self.onFinish = onFinish
    }
}

extension ProfileDescriptionRouterImpl: ProfileDescriptionRouter {
    func showPersonalPerfume(profileCalculation: ProfileCalculation?) {
        let screen = PersonalPerfumeModule.build(
            profileCalculation: profileCalculation,
            requestManager: requestManager,
            imageLoader: imageLoader,
            navigationController: navigationController,
            onFinish: onFinish
        )
        navigationController?.pushViewController(screen, animated: true)
    }

    func finishOnboarding() {
        onFinish?()
    }
}
