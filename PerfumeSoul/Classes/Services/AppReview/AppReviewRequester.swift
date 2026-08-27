//
//  AppReviewRequester.swift
//  PerfumeSoul
//
//  Created by afon.com on 03.08.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import StoreKit
import UIKit

protocol AppReviewRequester {
    @MainActor
    func registerQuizCompletion(for quizDayKey: String)
    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene)
    @MainActor
    func resetCompletedQuizCount()
}

final class AppReviewRequesterImpl {
    private enum Keys {
        static let completedQuizCount = "appReview.completedQuizCount"
        static let lastCountedQuizDayKey = "appReview.lastCountedQuizDayKey"
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

    @MainActor
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
        userDefaults.removeObject(forKey: Keys.completedQuizCount)
        return true
    }
}

extension AppReviewRequesterImpl: AppReviewRequester {
    @MainActor
    func registerQuizCompletion(for quizDayKey: String) {
        if
            let lastCountedQuizDayKey = userDefaults.string(forKey: Keys.lastCountedQuizDayKey),
            quizDayKey <= lastCountedQuizDayKey
        {
            return
        }

        userDefaults.set(quizDayKey, forKey: Keys.lastCountedQuizDayKey)
        let completedQuizCount = userDefaults.integer(forKey: Keys.completedQuizCount) + 1
        userDefaults.set(completedQuizCount, forKey: Keys.completedQuizCount)
    }

    @MainActor
    func requestReviewIfEligible(in windowScene: UIWindowScene) {
        guard consumeReviewRequestSlot() else {
            return
        }

        AppStore.requestReview(in: windowScene)
    }

    @MainActor
    func resetCompletedQuizCount() {
        userDefaults.removeObject(forKey: Keys.completedQuizCount)
        userDefaults.removeObject(forKey: Keys.lastCountedQuizDayKey)
    }
}
