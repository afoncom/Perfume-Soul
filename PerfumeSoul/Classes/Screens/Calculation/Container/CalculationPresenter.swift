//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CalculationPresenter {
    func continueButtonTapped()
}

final class CalculationPresenterImpl {
    private let viewModel: CalculationViewModel
    private let router: CalculationRouter
    private let profileService: ProfileService
    
    init(
        viewModel: CalculationViewModel,
        router: CalculationRouter,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
    }
}

extension CalculationPresenterImpl: CalculationPresenter {
    func continueButtonTapped() {
        let profile = Profile(
            name: viewModel.firstName,
            birthDate: viewModel.birthDate,
            birthTime: viewModel.birthTime,
            birthPlace: viewModel.birthPlace
        )
        profileService.saveProfile(profile)
        router.showProfileDescription()
    }
}
