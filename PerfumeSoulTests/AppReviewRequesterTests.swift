//
//  AppReviewRequesterTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 05.08.2026.
//

import XCTest
@testable import PerfumeSoul

final class AppReviewRequesterTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var appVersionProvider: AppVersionProviderMock!

    override func setUp() {
        super.setUp()
        suiteName = "AppReviewRequesterTests-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        appVersionProvider = AppVersionProviderMock(appVersion: "1.0")
    }

    override func tearDown() {
        appVersionProvider = nil
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testFreshInstallDoesNotRequestReviewUntilThirdQuizCompletion() {
        let requester = makeRequester()

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())
    }

    func testSameVersionDoesNotRepeatReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
    }

    func testVersionBumpKeepsQuizCountForAnotherReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())

        appVersionProvider.appVersion = "1.1"

        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())
    }

    func testResetCompletedQuizCountAllowsNewProfileToReachThreshold() {
        let requester = makeRequester()

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())

        requester.resetCompletedQuizCount()

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())
    }

    func testMissingVersionDoesNotRecordQuizCompletion() {
        let requester = makeRequester()
        appVersionProvider.appVersion = nil

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())

        appVersionProvider.appVersion = "1.0"

        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertFalse(requester.registerQuizCompletionAndCheckReviewEligibility())
        XCTAssertTrue(requester.registerQuizCompletionAndCheckReviewEligibility())
    }

    private func makeRequester() -> AppReviewRequesterImpl {
        AppReviewRequesterImpl(
            userDefaults: userDefaults,
            appVersionProvider: appVersionProvider
        )
    }
}

private final class AppVersionProviderMock {
    var appVersion: String?

    init(appVersion: String?) {
        self.appVersion = appVersion
    }
}

extension AppVersionProviderMock: AppVersionProvider {
    func currentAppVersion() -> String? {
        appVersion
    }
}
