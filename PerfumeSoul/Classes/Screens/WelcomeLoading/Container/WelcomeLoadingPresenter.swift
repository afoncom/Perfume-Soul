//
//  WelcomeLoadingPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol WelcomeLoadingPresenter {
    @MainActor
    func onTask() async
}

final class WelcomeLoadingPresenterImpl {
    private let viewModel: WelcomeLoadingViewModel
    private let router: WelcomeLoadingRouter
    private let profileService: ProfileService
    
    init(
        viewModel: WelcomeLoadingViewModel,
        router: WelcomeLoadingRouter,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
    }
}

extension WelcomeLoadingPresenterImpl: WelcomeLoadingPresenter {
    @MainActor
    func onTask() async {
        guard !viewModel.hasStartedLoading else {
            return
        }

        viewModel.hasStartedLoading = true

        let profile = await profileService.fetchProfile()

        if profile != nil {
            router.showMainScreen()
        } else {
            router.showProfileSetupScreen()
        }
    }
}
