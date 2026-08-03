//
//  AppReviewRequester.swift
//  PerfumeSoul
//
//  Created by afon.com on 03.08.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import StoreKit
import UIKit

final class AppReviewRequester {
    private enum Keys {
        static let didRequestReviewAfterQuizCompletion = "appReview.didRequestReviewAfterQuizCompletion"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func requestReview(in windowScene: UIWindowScene) {
        Task { @MainActor in
            AppStore.requestReview(in: windowScene)
        }
    }

    func requestReviewAfterQuizCompletion(in windowScene: UIWindowScene) {
        guard userDefaults.bool(forKey: Keys.didRequestReviewAfterQuizCompletion) == false else {
            return
        }

        userDefaults.set(true, forKey: Keys.didRequestReviewAfterQuizCompletion)
        requestReview(in: windowScene)
    }
}
