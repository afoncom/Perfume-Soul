//
//  QuizOfTheDayRouterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 09.08.2026.
//

import XCTest
import UIKit
@testable import PerfumeSoul

final class QuizOfTheDayRouterTests: XCTestCase {
    @MainActor
    func testMissingWindowSceneStillRegistersQuizCompletion() {
        let requester = AppReviewRequesterMock()
        let router = QuizOfTheDayRouterImpl(
            navigationController: nil,
            appReviewRequester: requester
        )

        router.requestAppReview(for: "2026-08-16")

        XCTAssertEqual(requester.registeredQuizDayKeys, ["2026-08-16"])
        XCTAssertFalse(requester.didRequestReview)
    }
}

private final class AppReviewRequesterMock: AppReviewRequester {
    var registeredQuizDayKeys: [String] = []
    var didRequestReview = false

    @MainActor
    func registerQuizCompletion(for quizDayKey: String) {
        registeredQuizDayKeys.append(quizDayKey)
    }

    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene) {
        didRequestReview = true
    }

    @MainActor
    func resetCompletedQuizCount() { }
}
