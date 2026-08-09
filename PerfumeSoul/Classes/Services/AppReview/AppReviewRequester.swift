//
//  AppReviewRequester.swift
//  PerfumeSoul
//
//  Created by afon.com on 03.08.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import StoreKit
import UIKit

protocol AppReviewRequesting {
    func registerQuizCompletion()
    func consumeReviewRequestSlot() -> Bool
    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene)
    func resetCompletedQuizCount()
}

final class AppReviewRequesterImpl {
    private enum Keys {
        static let completedQuizCount = "appReview.completedQuizCount"
        static let lastRequestedVersion = "appReview.lastRequestedVersion"
    }

    private let minimumCompletedQuizCount = 3
    private let userDefaults: UserDefaults
    private let appVersionProvider: AppVersionProvider

    init(
        userDefaults: UserDefaults = .standard,
        appVersionProvider: AppVersionProvider
    ) {
        self.userDefaults = userDefaults
        self.appVersionProvider = appVersionProvider
    }

    func registerQuizCompletion() {
        let completedQuizCount = userDefaults.integer(forKey: Keys.completedQuizCount) + 1
        userDefaults.set(completedQuizCount, forKey: Keys.completedQuizCount)
    }

    func consumeReviewRequestSlot() -> Bool {
        guard let appVersion = appVersionProvider.currentAppVersion() else {
            return false
        }

        let completedQuizCount = userDefaults.integer(forKey: Keys.completedQuizCount)
        guard completedQuizCount >= minimumCompletedQuizCount else {
            return false
        }

        guard userDefaults.string(forKey: Keys.lastRequestedVersion) != appVersion else {
            return false
        }

        userDefaults.set(appVersion, forKey: Keys.lastRequestedVersion)
        return true
    }

    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene) {
        guard consumeReviewRequestSlot() else {
            return
        }

        requestReview(in: windowScene)
    }

    func resetCompletedQuizCount() {
        userDefaults.removeObject(forKey: Keys.completedQuizCount)
    }

    @MainActor
    private func requestReview(in windowScene: UIWindowScene) {
        AppStore.requestReview(in: windowScene)
    }

}

extension AppReviewRequesterImpl: AppReviewRequesting {}
