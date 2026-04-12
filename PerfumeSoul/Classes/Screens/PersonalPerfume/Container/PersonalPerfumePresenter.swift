//
//  PersonalPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumePresenter {
    func continueButtonTapped()
}

final class PersonalPerfumePresenterImpl {
    private let viewModel: PersonalPerfumeViewModel
    private let router: PersonalPerfumeRouter
    private let profileService: ProfileService
    
    init(
        viewModel: PersonalPerfumeViewModel,
        router: PersonalPerfumeRouter,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
    }
}

extension PersonalPerfumePresenterImpl: PersonalPerfumePresenter {
    func continueButtonTapped() {
        router.finishOnboarding()
    }
}
