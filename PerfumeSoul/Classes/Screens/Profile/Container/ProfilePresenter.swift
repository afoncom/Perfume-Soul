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
    static let placeholderProfileNames = ["Laura", "Alex", "Emma"]

    private let viewModel: ProfileViewModel
    private let router: ProfileRouter
    private let profileService: ProfileService
    private let profileCalculationService: ProfileCalculationService
    private let quizProgressService: QuizProgressService
    private let dailyQuizStateStorage: DailyQuizStateStorage
    private let appReviewRequester: AppReviewRequester
    private let profileAvatarBuilder: ProfileAvatarBuilder
    
    init(
        viewModel: ProfileViewModel,
        router: ProfileRouter,
        profileService: ProfileService,
        profileCalculationService: ProfileCalculationService,
        quizProgressService: QuizProgressService,
        dailyQuizStateStorage: DailyQuizStateStorage,
        appReviewRequester: AppReviewRequester,
        profileAvatarBuilder: ProfileAvatarBuilder
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
        self.profileCalculationService = profileCalculationService
        self.quizProgressService = quizProgressService
        self.dailyQuizStateStorage = dailyQuizStateStorage
        self.appReviewRequester = appReviewRequester
        self.profileAvatarBuilder = profileAvatarBuilder
    }
}

extension ProfilePresenterImpl: ProfilePresenter {
    func addedNewProfilesButtonTab() {
        router.showAddedNewProfiles()
    }
    
    func personalPerfumesButtonTapped() async {
        let profileCalculationState = await MainActor.run {
            viewModel.profileCalculationState
        }

        switch profileCalculationState {
        case .loaded(let profileCalculation):
            await MainActor.run {
                router.showPersonalPerfumes(profileCalculation: profileCalculation)
            }
        case .loading:
            return
        case .missingBirthPlaceData, .invalidBirthData:
            await completeBirthDataButtonTapped()
        case .idle, .failed:
            await loadProfileCalculationAndOpenPersonalPerfumes()
        }
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
        let profile = await MainActor.run {
            viewModel.profile
        }

        guard let profile else {
            return
        }

        await MainActor.run {
            router.showProfileSetupScreen(profile: profile)
        }
    }

    func onAppear() async {
        let profile = await profileService.fetchProfile()
        let quizProgress = quizProgressService.loadProgress()
        let addedProfileItems = makeAddedProfileItems()

        await MainActor.run {
            setProfile(profile)
            viewModel.addedProfileItems = addedProfileItems
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
        appReviewRequester.resetCompletedQuizCount()
        
        await MainActor.run {
            setProfile(nil)
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

    private func makeAddedProfileItems() -> [AddedProfileItem] {
        Self.placeholderProfileNames.map { name in
            AddedProfileItem(
                id: name,
                name: name,
                avatar: profileAvatarBuilder.makeAvatar(name: name)
            )
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

        if let cachedProfileCalculation = profile.cachedProfileCalculation {
            await MainActor.run {
                viewModel.profileCalculationState = .loaded(cachedProfileCalculation)
            }
            return
        }

        await MainActor.run {
            viewModel.profileCalculationState = .loading
        }

        do {
            let profileCalculation = try await profileCalculationService.calculate(profile: profile)
            let updatedProfile = profile.withProfileCalculation(profileCalculation)
            await profileService.replaceProfile(updatedProfile)

            await MainActor.run {
                setProfile(updatedProfile)
                viewModel.profileCalculationState = .loaded(profileCalculation)
            }
        } catch is ProfileCalculationError {
            await MainActor.run {
                viewModel.profileCalculationState = .invalidBirthData
            }
        } catch {
            await MainActor.run {
                viewModel.profileCalculationState = .failed
            }
        }
    }

    private func setProfile(_ profile: Profile?) {
        viewModel.profile = profile
        viewModel.avatar = profile.map { profileAvatarBuilder.makeAvatar(name: $0.name) }
    }
}
