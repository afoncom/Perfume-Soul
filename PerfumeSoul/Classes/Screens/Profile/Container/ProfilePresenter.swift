//
//  ProfilePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfilePresenter {
    func addedNewProfilesButtonTab()
    @MainActor
    func onAppear() async
    @MainActor
    func deleteProfile() async
}

final class ProfilePresenterImpl {
    private let viewModel: ProfileViewModel
    private let router: ProfileRouter
    private let profileService: ProfileService
    
    init(
        viewModel: ProfileViewModel,
        router: ProfileRouter,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
    }
}

extension ProfilePresenterImpl: ProfilePresenter {
    func addedNewProfilesButtonTab() {
        router.showAddedNewProfiles()
    }

    @MainActor
    func onAppear() async {
        let profile = await profileService.fetchProfile()
        viewModel.profile = profile
    }
    
    @MainActor
    func deleteProfile() async {
        guard let profile = viewModel.profile else { return }
        await profileService.deleteProfile(profile)
        viewModel.profile = nil
        router.showCalculationScreen()
    }
}
