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
    func retryButtonTapped() async
    func skipButtonTapped()
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
        guard let profileCalculation = viewModel.profileCalculation else {
            return
        }

        router.showPersonalPerfume(profileCalculation: profileCalculation)
    }

    func retryButtonTapped() async {
        let profile = await MainActor.run {
            viewModel.profile
        }

        await loadProfileDescription(profile: profile)
    }

    func skipButtonTapped() {
        router.finishOnboarding()
    }
    
    func onAppear() async {
        let profile = await profileService.fetchProfile()

        await MainActor.run {
            viewModel.profile = profile
        }

        await loadProfileDescription(profile: profile)
    }
}

extension ProfileDescriptionPresenterImpl {
    private func loadProfileDescription(profile: Profile?) async {
        guard let profile else {
            await MainActor.run {
                viewModel.state = .idle
            }
            return
        }

        guard profile.hasCompleteBirthPlaceData else {
            await MainActor.run {
                viewModel.state = .missingBirthPlaceData
            }
            return
        }

        await MainActor.run {
            viewModel.state = .loading
        }

        do {
            let calculation = try await profileCalculationService.calculate(profile: profile)
            let updatedProfile = profile.withCalculatedSunSign(calculation.natalChart.sun.sign)
            let profileDescription = profileDescriptionBuilder.build(
                profile: updatedProfile,
                calculation: calculation
            )
            await profileService.replaceProfile(updatedProfile)

            await MainActor.run {
                viewModel.profile = updatedProfile
                viewModel.state = .content(calculation, profileDescription)
            }
        } catch is ProfileCalculationError {
            await MainActor.run {
                viewModel.state = .invalidBirthData
            }
        } catch {
            await MainActor.run {
                viewModel.state = .failed
            }
        }
    }
}
