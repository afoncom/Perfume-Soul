//
//  ProfilePresenterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 19.08.2026.
//

import XCTest
import UIKit
import UserNotifications
@testable import PerfumeSoul

final class ProfilePresenterTests: XCTestCase {
    @MainActor
    func testDeleteProfileRemovesDailyPerfumeReminderAndResetsItsPreference() async throws {
        let suite = "tests.profileNotification.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: DailyNotificationKind.dailyPerfume.preferenceKey)
        defaults.set(true, forKey: DailyNotificationKind.history.preferenceKey)
        let scheduler = ProfileNotificationScheduler()
        let notifications = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: ProfileServiceMock(),
            userDefaults: defaults
        )
        let viewModel = ProfileViewModel()
        viewModel.profile = makeProfile()
        let presenter = makePresenter(
            viewModel: viewModel,
            appReviewRequester: AppReviewRequesterMock(),
            notificationService: notifications
        )
        let enabled = await notifications.isNotificationEnabled(for: .dailyPerfume)
        XCTAssertTrue(enabled)

        await presenter.deleteProfile()

        XCTAssertFalse(defaults.bool(forKey: DailyNotificationKind.dailyPerfume.preferenceKey))
        XCTAssertEqual(scheduler.pendingIdentifiers, [DailyNotificationKind.history.identifier])
        let stillEnabled = await notifications.isNotificationEnabled(for: .dailyPerfume)
        XCTAssertFalse(stillEnabled)
        XCTAssertTrue(defaults.bool(forKey: DailyNotificationKind.history.preferenceKey))
    }

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

    @MainActor
    func testDeleteProfileClearsDailyPerfumeState() async {
        let viewModel = ProfileViewModel()
        let dailyPerfumeStateStorage: ViewStateStorage<DailyPerfumeState> = makeStorage()
        dailyPerfumeStateStorage.saveState(makeDailyPerfumeState())
        viewModel.profile = makeProfile()
        let presenter = makePresenter(
            viewModel: viewModel,
            appReviewRequester: AppReviewRequesterMock(),
            dailyPerfumeStateStorage: dailyPerfumeStateStorage
        )

        await presenter.deleteProfile()

        XCTAssertNil(dailyPerfumeStateStorage.loadState())
    }

    private func makePresenter(
        viewModel: ProfileViewModel,
        appReviewRequester: AppReviewRequesterMock,
        dailyPerfumeStateStorage: ViewStateStorage<DailyPerfumeState>? = nil,
        notificationService: DailyNotificationService = ProfileNotificationServiceMock()
    ) -> ProfilePresenterImpl {
        ProfilePresenterImpl(
            viewModel: viewModel,
            router: ProfileRouterMock(),
            profileService: ProfileServiceMock(),
            profileCalculationService: ProfileCalculationServiceMock(),
            quizProgressService: QuizProgressServiceMock(),
            dailyQuizStateStorage: makeStorage(),
            dailyPerfumeStateStorage: dailyPerfumeStateStorage ?? makeStorage(),
            collectionService: PerfumeCollectionServiceMock(),
            personalPerfumeTopStorage: PersonalPerfumeTopStorageMock(),
            recommendedPerfumeStateStorage: makeStorage(),
            appReviewRequester: appReviewRequester,
            profileAvatarBuilder: ProfileAvatarBuilderMock(),
            notificationService: notificationService
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

    private func makeStorage<State: StorableViewState>() -> ViewStateStorage<State> {
        ViewStateStorage(
            userDefaults: .standard,
            storableKey: "tests.profile.\(UUID().uuidString)"
        )
    }

    private func makeDailyPerfumeState() -> DailyPerfumeState {
        DailyPerfumeState(
            profileCalculationCacheKey: nil,
            dayKey: "2026-10-11",
            currentPerfume: nil,
            currentReaction: nil,
            shownPerfumeIDs: [],
            savedPerfumes: [],
            dislikedPerfumeIDs: [],
            lastShownBrand: nil
        )
    }
}

private final class ProfileNotificationServiceMock: DailyNotificationService {
    func isNotificationEnabled(for kind: DailyNotificationKind) async -> Bool { false }
    func enableNotification(for kind: DailyNotificationKind) async throws { }
    func disableNotification(for kind: DailyNotificationKind) async { }
}

private final class ProfileNotificationScheduler: UserNotificationScheduling {
    var pendingIdentifiers: Set<String> = [DailyNotificationKind.dailyPerfume.identifier, DailyNotificationKind.history.identifier]
    func authorizationStatus() async -> UNAuthorizationStatus { .authorized }
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { true }
    func add(_ request: UNNotificationRequest) async throws { pendingIdentifiers.insert(request.identifier) }
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pendingIdentifiers.subtract(identifiers)
    }
}

private final class ProfileRouterMock: ProfileRouter {
    func showCabinet() { }
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
    func loadProgress() async -> QuizProgress { .initial }
    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress { .initial }
    func completeQuiz(for quizDayKey: String) async -> QuizProgress { .initial }
    func resetProgress() async { }
}

private final class PerfumeCollectionServiceMock: PerfumeCollectionService {
    func loadState() -> PerfumeCollectionState { .empty }
    func save(_ perfume: PerfumeCollectionPerfume) { }
    func removeSavedPerfume(id: Int) { }
    func dislikePerfume(id: Int) { }
    func clearState() { }
}

private final class PersonalPerfumeTopStorageMock: PersonalPerfumeTopStorage {
    func loadPerfumeIDs() -> [Int] { [] }
    func savePerfumeIDs(_ perfumeIDs: [Int]) { }
    func clear() { }
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
