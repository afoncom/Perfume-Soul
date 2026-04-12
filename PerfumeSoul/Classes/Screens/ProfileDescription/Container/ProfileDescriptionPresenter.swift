//
//  ProfileDescriptionPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfileDescriptionPresenter {
    
}

final class ProfileDescriptionPresenterImpl {
    private let viewModel: ProfileDescriptionViewModel
    private let router: ProfileDescriptionRouter
    private let profileService: ProfileService
    
    init(
        viewModel: ProfileDescriptionViewModel,
        router: ProfileDescriptionRouter,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
    }
}

extension ProfileDescriptionPresenterImpl: ProfileDescriptionPresenter {
    
}
