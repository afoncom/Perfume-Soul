//
//  ProfilePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfilePresenter {
    func addedNewProfilesButtonTab()
    func personalPerfumesButtonTapped() async
    func profileDescriptionButtonTapped()
    func retryProfileCalculationButtonTapped() async
    func completeBirthDataButtonTapped() async
    func onAppear() async
    func deleteProfile() async
}

final class ProfilePresenterImpl {
    private let viewModel: ProfileViewModel
    private let router: ProfileRouter
    private let profileService: ProfileService
    private let profileCalculationService: ProfileCalculationService
    private let quizProgressService: QuizProgressService
    private let dailyQuizStateStorage: DailyQuizStateStorage
    
    init(
        viewModel: ProfileViewModel,
        router: ProfileRouter,
        profileService: ProfileService,
        profileCalculationService: ProfileCalculationService,
        quizProgressService: QuizProgressService,
        dailyQuizStateStorage: DailyQuizStateStorage
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
        self.profileCalculationService = profileCalculationService
        self.quizProgressService = quizProgressService
        self.dailyQuizStateStorage = dailyQuizStateStorage
    }
}

extension ProfilePresenterImpl: ProfilePresenter {
    func addedNewProfilesButtonTab() {
        router.showAddedNewProfiles()
    }
    
    func personalPerfumesButtonTapped() async {
        if let profileCalculation = await MainActor.run(body: { viewModel.profileCalculation }) {
            await MainActor.run {
                router.showPersonalPerfumes(profileCalculation: profileCalculation)
            }
            return
        }

        let isProfileCalculationLoading = await MainActor.run {
            viewModel.isProfileCalculationLoading
        }

        guard !isProfileCalculationLoading else {
            return
        }

        await loadProfileCalculationAndOpenPersonalPerfumes()
    }

    func profileDescriptionButtonTapped() {
        router.showProfileDescription()
    }

    func retryProfileCalculationButtonTapped() async {
        let profile = await MainActor.run {
            viewModel.profile
        }

        await loadProfileCalculation(profile: profile)
    }

    func completeBirthDataButtonTapped() async {
        await MainActor.run {
            router.showProfileSetupScreen()
        }
    }

    func onAppear() async {
        let profile = await profileService.fetchProfile()
        let quizProgress = quizProgressService.loadProgress()

        await MainActor.run {
            viewModel.profile = profile
            viewModel.totalCorrectQuizAnswers = quizProgress.totalCorrectQuizAnswers
        }

        await loadProfileCalculation(profile: profile)
    }
    
    func deleteProfile() async {
        let profile = await MainActor.run {
            viewModel.profile
        }
        guard let profile else {
            return
        }
        
        await profileService.deleteProfile(profile)
        quizProgressService.resetProgress()
        dailyQuizStateStorage.clearState()
        
        await MainActor.run {
            viewModel.profile = nil
            viewModel.profileCalculationState = .idle
            viewModel.totalCorrectQuizAnswers = 0
            router.showCalculationScreen()
        }
    }
}

extension ProfilePresenterImpl {
    private func loadProfileCalculationAndOpenPersonalPerfumes() async {
        let profile = await MainActor.run {
            viewModel.profile
        }

        await loadProfileCalculation(profile: profile)

        if let profileCalculation = await MainActor.run(body: { viewModel.profileCalculation }) {
            await MainActor.run {
                router.showPersonalPerfumes(profileCalculation: profileCalculation)
            }
        }
    }

    private func loadProfileCalculation(profile: Profile?) async {
        guard let profile else {
            await MainActor.run {
                viewModel.profileCalculationState = .idle
            }
            return
        }

        guard profile.hasCompleteBirthPlaceData else {
            await MainActor.run {
                viewModel.profileCalculationState = .missingBirthPlaceData
            }
            return
        }

        await MainActor.run {
            viewModel.profileCalculationState = .loading
        }

        do {
            let profileCalculation = try await profileCalculationService.calculate(profile: profile)
            await MainActor.run {
                viewModel.profileCalculationState = .loaded(profileCalculation)
            }
        } catch {
            await MainActor.run {
                viewModel.profileCalculationState = .failed
            }
        }
    }
}
