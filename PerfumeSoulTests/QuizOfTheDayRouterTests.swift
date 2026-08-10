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

        router.requestAppReview()

        XCTAssertEqual(requester.registeredCompletions, 1)
        XCTAssertFalse(requester.didRequestReview)
    }
}

private final class AppReviewRequesterMock: AppReviewRequesting {
    var registeredCompletions = 0
    var didRequestReview = false

    func registerQuizCompletion() {
        registeredCompletions += 1
    }

    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene) {
        didRequestReview = true
    }

    func resetCompletedQuizCount() { }
}
