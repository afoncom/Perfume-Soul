//
//  ProfileDescriptionPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfileDescriptionPresenter {
    var shouldShowContinueButton: Bool { get }

    func continueButtonTapped()
    func onAppear() async
}

final class ProfileDescriptionPresenterImpl {
    private let viewModel: ProfileDescriptionViewModel
    private let router: ProfileDescriptionRouter
    private let profileService: ProfileService
    private let profileCalculationService: ProfileCalculationService
    private let profileDescriptionBuilder: ProfileDescriptionBuilder
    let shouldShowContinueButton: Bool
    
    init(
        viewModel: ProfileDescriptionViewModel,
        router: ProfileDescriptionRouter,
        profileService: ProfileService,
        profileCalculationService: ProfileCalculationService,
        profileDescriptionBuilder: ProfileDescriptionBuilder,
        shouldShowContinueButton: Bool
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
        self.profileCalculationService = profileCalculationService
        self.profileDescriptionBuilder = profileDescriptionBuilder
        self.shouldShowContinueButton = shouldShowContinueButton
    }
}

extension ProfileDescriptionPresenterImpl: ProfileDescriptionPresenter {
    func continueButtonTapped() {
        router.showPersonalPerfume()
    }
    
    func onAppear() async {
        let profile = await profileService.fetchProfile()
        let profileDescription: ProfileDescription?

        if
            let profile,
            profile.hasCompleteBirthPlaceData,
            let calculation = try? await profileCalculationService.calculate(profile: profile)
        {
            profileDescription = profileDescriptionBuilder.build(
                profile: profile,
                calculation: calculation
            )
        } else {
            profileDescription = nil
        }

        await MainActor.run {
            viewModel.profile = profile
            viewModel.profileDescription = profileDescription
        }
    }
}
