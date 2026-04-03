//
//  ProfilePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfilePresenter {
    func addedNewProfilesButtonTab()
    func onAppear() async
}

final class ProfilePresenterImpl {
    private let viewModel: ProfileViewMoodel
    private let router: ProfileRouter
    private let profileService: ProfileService
    
    init(
        viewModel: ProfileViewMoodel,
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

    func onAppear() async {
        let profiles = await profileService.fechProfile()
        viewModel.profileName = profiles.last?.name ?? ""
    }
}
