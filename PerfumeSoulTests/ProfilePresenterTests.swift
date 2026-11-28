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
    func testDeletingProfileDuringReminderAddLeavesReminderDisabled() async throws {
        try await checkDeletingProfileDuringReminderAdd(failedRetry: false)
    }

    @MainActor
    func testFailedEnableCannotInvalidatePendingProfileDeletionDisable() async throws {
        try await checkDeletingProfileDuringReminderAdd(failedRetry: true)
    }

    @MainActor
    func testDeletingProfileCannotBeOverwrittenByAnEnableFlagCommit() async throws {
        let suite = "tests.profileNotification.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(ProfileNotificationDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let scheduler = ProfileNotificationScheduler()
        let profile = makeCalculatedProfile()
        let profileService = ProfileServiceMock(profile: profile)
        let notifications = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: profileService,
            userDefaults: defaults
        )
        let viewModel = ProfileViewModel()
        viewModel.profile = profile
        let presenter = makePresenter(
            viewModel: viewModel,
            appReviewRequester: AppReviewRequesterMock(),
            notificationService: notifications,
            profileService: profileService
        )
        let writeStarted = expectation(description: "Enable reached its true flag write")
        let disableInterleaved = expectation(description: "Disable must not interrupt the flag commit")
        disableInterleaved.isInverted = true
        let resumeWrite = DispatchSemaphore(value: 0)
        let writeReleased = DispatchSemaphore(value: 0)
        defer { resumeWrite.signal() }
        defaults.onWillEnableDailyPerfume = {
            writeStarted.fulfill()
            if resumeWrite.wait(timeout: .now() + 5) == .timedOut {
                XCTFail("The paused flag write was not released")
            }
        }
        defaults.onDailyPerfumeDisabled = {
            if writeReleased.wait(timeout: .now()) == .timedOut {
                disableInterleaved.fulfill()
            } else {
                writeReleased.signal()
            }
        }
        let enabling = Task { try await notifications.enableNotification(for: .dailyPerfume) }
        await fulfillment(of: [writeStarted], timeout: 2)
        let deleting = Task { await presenter.deleteProfile() }
        // Pause after version validation, before UserDefaults stores true.
        // The coordinator must keep disable's false write outside that commit.
        await fulfillment(of: [disableInterleaved], timeout: 1)
        writeReleased.signal()
        resumeWrite.signal()
        try await enabling.value
        await deleting.value

        XCTAssertFalse(defaults.bool(forKey: DailyNotificationKind.dailyPerfume.preferenceKey))
        XCTAssertFalse(scheduler.pendingIdentifiers.contains(DailyNotificationKind.dailyPerfume.identifier))
        let enabled = await notifications.isNotificationEnabled(for: .dailyPerfume)
        XCTAssertFalse(enabled)
    }

    @MainActor
    private func checkDeletingProfileDuringReminderAdd(failedRetry: Bool) async throws {
        let suite = "tests.profileNotification.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(ProfileNotificationDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: DailyNotificationKind.dailyPerfume.preferenceKey)
        defaults.set(true, forKey: DailyNotificationKind.history.preferenceKey)
        let profile = makeCalculatedProfile()
        let profileService = ProfileServiceMock(profile: profile)
        let scheduler = ProfileNotificationScheduler()
        scheduler.pendingIdentifiers = [DailyNotificationKind.history.identifier]
        let addStarted = expectation(description: "Settings reminder add suspended")
        let disableStarted = expectation(description: "Profile deletion disabled reminder")
        scheduler.onAddStarted = { addStarted.fulfill() }
        defaults.onDailyPerfumeDisabled = { disableStarted.fulfill() }
        let notifications = DailyNotificationServiceImpl(
            userNotificationCenter: scheduler,
            profileService: profileService,
            userDefaults: defaults
        )
        let viewModel = ProfileViewModel()
        viewModel.profile = profile
        let presenter = makePresenter(
            viewModel: viewModel,
            appReviewRequester: AppReviewRequesterMock(),
            notificationService: notifications,
            profileService: profileService
        )
        let enabling = Task { try await notifications.enableNotification(for: .dailyPerfume) }
        await fulfillment(of: [addStarted], timeout: 2)
        let deleting = Task { await presenter.deleteProfile() }
        await fulfillment(of: [disableStarted], timeout: 2)
        if failedRetry {
            do {
                try await notifications.enableNotification(for: .dailyPerfume)
                XCTFail("Enabling without a profile must fail")
            } catch DailyNotificationServiceError.profileUnavailable {
                // A failed enable must preserve the removal queued by profile deletion.
            }
        }
        scheduler.resumeAdd()
        try await enabling.value
        await deleting.value

        let remainingProfile = await profileService.fetchProfile()
        XCTAssertNil(remainingProfile)
        XCTAssertFalse(defaults.bool(forKey: DailyNotificationKind.dailyPerfume.preferenceKey))
        XCTAssertEqual(scheduler.pendingIdentifiers, [DailyNotificationKind.history.identifier])
        let enabled = await notifications.isNotificationEnabled(for: .dailyPerfume)
        XCTAssertFalse(enabled)
        XCTAssertTrue(defaults.bool(forKey: DailyNotificationKind.history.preferenceKey))
    }

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
        notificationService: DailyNotificationService = ProfileNotificationServiceMock(),
        profileService: ProfileService = ProfileServiceMock()
    ) -> ProfilePresenterImpl {
        ProfilePresenterImpl(
            viewModel: viewModel,
            router: ProfileRouterMock(),
            profileService: profileService,
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

    private func makeCalculatedProfile() -> Profile {
        makeProfile().withProfileCalculation(ProfileCalculation(
            natalChart: NatalChart(
                sun: ZodiacPlacement(sign: .aquarius, longitude: 0),
                moon: ZodiacPlacement(sign: .aquarius, longitude: 0),
                ascendant: ZodiacPlacement(sign: .aquarius, longitude: 0)
            ),
            elementBalance: ElementBalance(fire: 0, earth: 0, air: 100, water: 0)
        ))
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
    var onAddStarted: (() -> Void)?
    private var addContinuation: CheckedContinuation<Void, Never>?
    func add(_ request: UNNotificationRequest) async throws {
        if let onAddStarted {
            await withCheckedContinuation { continuation in
                addContinuation = continuation
                onAddStarted()
            }
        }
        pendingIdentifiers.insert(request.identifier)
    }
    func resumeAdd() {
        addContinuation?.resume()
        addContinuation = nil
    }
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

private final class ProfileNotificationDefaults: UserDefaults {
    var onDailyPerfumeDisabled: (() -> Void)?
    var onWillEnableDailyPerfume: (() -> Void)?
    override func set(_ value: Bool, forKey defaultName: String) {
        if defaultName == DailyNotificationKind.dailyPerfume.preferenceKey, value {
            onWillEnableDailyPerfume?()
        }
        super.set(value, forKey: defaultName)
        if defaultName == DailyNotificationKind.dailyPerfume.preferenceKey, !value {
            onDailyPerfumeDisabled?()
        }
    }
}

private final class ProfileServiceMock: ProfileService {
    private var profile: Profile?
    init(profile: Profile? = nil) { self.profile = profile }
    func saveProfile(_ profile: Profile) { }
    func replaceProfile(_ profile: Profile) async { }
    func fetchProfile() async -> Profile? { profile }
    func deleteProfile(_ profile: Profile) async { self.profile = nil }
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
