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
        appVersionProvider = AppVersionProviderMock(appVersion: "1.0-1")
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

        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertTrue(requester.recordQuizCompletionAndCheckReviewRequest())
    }

    func testSameVersionDoesNotRepeatReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertTrue(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
    }

    func testVersionBumpResetsQuizCountBeforeReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertTrue(requester.recordQuizCompletionAndCheckReviewRequest())

        appVersionProvider.appVersion = "1.1-2"

        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertFalse(requester.recordQuizCompletionAndCheckReviewRequest())
        XCTAssertTrue(requester.recordQuizCompletionAndCheckReviewRequest())
    }

    private func makeRequester() -> AppReviewRequesterImpl {
        AppReviewRequesterImpl(
            userDefaults: userDefaults,
            appVersionProvider: appVersionProvider
        )
    }
}

private final class AppVersionProviderMock {
    var appVersion: String

    init(appVersion: String) {
        self.appVersion = appVersion
    }
}

extension AppVersionProviderMock: AppVersionProvider {
    func currentAppVersion() -> String {
        appVersion
    }
}
