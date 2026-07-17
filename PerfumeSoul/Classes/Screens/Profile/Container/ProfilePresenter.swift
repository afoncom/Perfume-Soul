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
    func profileDescriptionButtonTapped()
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
    
    func personalPerfumesButtonTapped() {
        router.showPersonalPerfumes()
    }

    func profileDescriptionButtonTapped() {
        router.showProfileDescription()
    }

    func onAppear() async {
        let profile = await profileService.fetchProfile()
        let quizProgress = quizProgressService.loadProgress()
        let profileCalculation: ProfileCalculation?

        if let profile, profile.hasCompleteBirthPlaceData {
            profileCalculation = try? await profileCalculationService.calculate(profile: profile)
        } else {
            profileCalculation = nil
        }

        await MainActor.run {
            viewModel.profile = profile
            viewModel.profileCalculation = profileCalculation
            viewModel.totalCorrectQuizAnswers = quizProgress.totalCorrectQuizAnswers
        }
    }
    
    func deleteProfile() async {
        let profile = await MainActor.run {
            viewModel.profile
        }
        guard let profile else { return }
        
        await profileService.deleteProfile(profile)
        quizProgressService.resetProgress()
        dailyQuizStateStorage.clearState()
        
        await MainActor.run {
            viewModel.profile = nil
            viewModel.profileCalculation = nil
            viewModel.totalCorrectQuizAnswers = 0
            router.showCalculationScreen()
        }
    }
}
