//
//  WelcomeLoadingRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//


protocol WelcomeLoadingRouter {
    func showMainScreen()
    func showProfileSetupScreen()
}

final class WelcomeLoadingRouterImpl {
    private let onProfileExists: () -> Void
    private let onProfileMissing: () -> Void

    init(
        onProfileExists: @escaping () -> Void,
        onProfileMissing: @escaping () -> Void
    ) {
        self.onProfileExists = onProfileExists
        self.onProfileMissing = onProfileMissing
    }
}

extension WelcomeLoadingRouterImpl: WelcomeLoadingRouter {
    func showMainScreen() {
        onProfileExists()
    }

    func showProfileSetupScreen() {
        onProfileMissing()
    }
}
