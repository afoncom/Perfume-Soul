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

    func testReviewSlotOpensOnThirdQuizCompletion() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        XCTAssertFalse(requester.consumeReviewRequestSlot())

        requester.registerQuizCompletion()

        XCTAssertTrue(requester.consumeReviewRequestSlot())
    }

    func testReviewSlotIsConsumedOnlyOncePerVersion() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        XCTAssertTrue(requester.consumeReviewRequestSlot())
        XCTAssertFalse(requester.consumeReviewRequestSlot())

        appVersionProvider.appVersion = "1.1"

        XCTAssertTrue(requester.consumeReviewRequestSlot())
    }

    func testResetCompletedQuizCountAllowsNewProfileToReachThreshold() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        requester.resetCompletedQuizCount()

        XCTAssertFalse(requester.consumeReviewRequestSlot())

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        XCTAssertTrue(requester.consumeReviewRequestSlot())
    }

    func testMissingVersionDoesNotConsumeReviewSlot() {
        let requester = makeRequester()

        requester.registerQuizCompletion()
        requester.registerQuizCompletion()
        requester.registerQuizCompletion()

        appVersionProvider.appVersion = nil

        XCTAssertFalse(requester.consumeReviewRequestSlot())
        XCTAssertNil(userDefaults.string(forKey: "appReview.lastRequestedVersion"))
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
