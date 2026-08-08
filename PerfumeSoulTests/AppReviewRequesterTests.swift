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

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        XCTAssertEqual(userDefaults.integer(forKey: "appReview.completedQuizCount"), 3)
    }

    func testQuizCompletionCountContinuesAcrossVersions() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        appVersionProvider.appVersion = "1.1"
        requester.registerQuizCompletion()

        XCTAssertEqual(userDefaults.integer(forKey: "appReview.completedQuizCount"), 3)
    }

    func testResetCompletedQuizCountAllowsNewProfileToReachThreshold() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        requester.resetCompletedQuizCount()

        XCTAssertEqual(userDefaults.integer(forKey: "appReview.completedQuizCount"), 0)
    }

    func testMissingVersionDoesNotRecordQuizCompletion() {
        let requester = makeRequester()
        appVersionProvider.appVersion = nil

        requester.registerQuizCompletion()

        appVersionProvider.appVersion = "1.0"

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        XCTAssertEqual(userDefaults.integer(forKey: "appReview.completedQuizCount"), 3)
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
