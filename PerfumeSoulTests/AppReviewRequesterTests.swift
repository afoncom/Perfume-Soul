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

        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertTrue(requester.shouldRequestReviewAfterQuizCompletion())
    }

    func testSameVersionDoesNotRepeatReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertTrue(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
    }

    func testVersionBumpResetsQuizCountBeforeReviewRequest() {
        let requester = makeRequester()

        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertTrue(requester.shouldRequestReviewAfterQuizCompletion())

        appVersionProvider.appVersion = "1.1-2"

        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertFalse(requester.shouldRequestReviewAfterQuizCompletion())
        XCTAssertTrue(requester.shouldRequestReviewAfterQuizCompletion())
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
