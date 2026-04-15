//
//  ProfilePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfilePresenter {
    func addedNewProfilesButtonTab()
    func personalPerfumesButtonTapped()
    func onAppear() async
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
    
    func personalPerfumesButtonTapped() {
        router.showPersonalPerfumes()
    }

    func onAppear() async {
        let profile = await profileService.fetchProfile()
        await MainActor.run {
            viewModel.profile = profile
        }
    }
    
    func deleteProfile() async {
        let profile = await MainActor.run {
            viewModel.profile
        }
        guard let profile else { return }
        
        await profileService.deleteProfile(profile)
        
        await MainActor.run {
            viewModel.profile = nil
            router.showCalculationScreen()
        }
    }
}
