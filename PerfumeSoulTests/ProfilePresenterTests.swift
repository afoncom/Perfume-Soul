//
//  ProfilePresenterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 19.08.2026.
//

import XCTest
import UIKit
@testable import PerfumeSoul

final class ProfilePresenterTests: XCTestCase {
    @MainActor
    func testDeleteProfileResetsCompletedQuizCount() async {
        let viewModel = ProfileViewModel()
        let appReviewRequester = AppReviewRequesterMock()
        viewModel.profile = makeProfile()
        let presenter = makePresenter(
            viewModel: viewModel,
            appReviewRequester: appReviewRequester
        )

        await presenter.deleteProfile()

        XCTAssertTrue(appReviewRequester.didResetCompletedQuizCount)
    }

    private func makePresenter(
        viewModel: ProfileViewModel,
        appReviewRequester: AppReviewRequesterMock
    ) -> ProfilePresenterImpl {
        ProfilePresenterImpl(
            viewModel: viewModel,
            router: ProfileRouterMock(),
            profileService: ProfileServiceMock(),
            profileCalculationService: ProfileCalculationServiceMock(),
            quizProgressService: QuizProgressServiceMock(),
            dailyQuizStateStorage: DailyQuizStateStorageMock(),
            appReviewRequester: appReviewRequester,
            profileAvatarBuilder: ProfileAvatarBuilderMock()
        )
    }

    private func makeProfile() -> Profile {
        Profile(
            name: "Alex",
            birthDate: "01.01.1990",
            birthTime: "12:00",
            birthPlace: "Madrid",
            birthLatitude: 40.4168,
            birthLongitude: -3.7038,
            birthTimeZoneIdentifier: "Europe/Madrid"
        )
    }
}

private final class ProfileRouterMock: ProfileRouter {
    func showPersonalPerfumes(profileCalculation: ProfileCalculation?) { }
    func showProfileDescription() { }
    func showProfileSetupScreen(profile: Profile) { }
    func showCalculationScreen() { }
}

private final class ProfileServiceMock: ProfileService {
    func saveProfile(_ profile: Profile) { }
    func replaceProfile(_ profile: Profile) async { }
    func fetchProfile() async -> Profile? { nil }
    func deleteProfile(_ profile: Profile) async { }
}

private final class ProfileCalculationServiceMock: ProfileCalculationService {
    func calculate(profile: Profile) async throws -> ProfileCalculation {
        throw ProfileCalculationError.invalidProfileData
    }
}

private final class QuizProgressServiceMock: QuizProgressService {
    func loadProgress() -> QuizProgress { .initial }
    func recordCorrectAnswer(questionID: Int, quizDayKey: String) -> QuizProgress { .initial }
    func completeQuiz(for quizDayKey: String) -> QuizProgress { .initial }
    func resetProgress() { }
}

private final class DailyQuizStateStorageMock: DailyQuizStateStorage {
    func loadState() -> DailyQuizState? { nil }
    func saveState(_ state: DailyQuizState) { }
    func clearState() { }
}

private final class AppReviewRequesterMock: AppReviewRequester {
    var didResetCompletedQuizCount = false

    @MainActor
    func registerQuizCompletion(for quizDayKey: String) { }

    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene) { }

    @MainActor
    func resetCompletedQuizCount() {
        didResetCompletedQuizCount = true
    }
}

private final class ProfileAvatarBuilderMock: ProfileAvatarBuilder {
    func makeAvatar(name: String) -> ProfileAvatar {
        .placeholder
    }
}
