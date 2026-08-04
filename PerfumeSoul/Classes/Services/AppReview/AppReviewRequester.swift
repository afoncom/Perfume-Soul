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
    @MainActor
    func requestReviewAfterQuizCompletion(in windowScene: UIWindowScene)
}

final class AppReviewRequesterImpl {
    private enum Keys {
        static let completedQuizCount = "appReview.completedQuizCount"
        static let completedQuizCountVersion = "appReview.completedQuizCountVersion"
        static let lastRequestedVersion = "appReview.lastRequestedVersion"
    }

    private let minimumCompletedQuizCount = 3
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    @MainActor
    func requestReviewAfterQuizCompletion(in windowScene: UIWindowScene) {
        let appVersion = currentAppVersion
        resetCompletedQuizCountIfNeeded(for: appVersion)

        let completedQuizCount = userDefaults.integer(forKey: Keys.completedQuizCount) + 1
        userDefaults.set(completedQuizCount, forKey: Keys.completedQuizCount)

        guard completedQuizCount >= minimumCompletedQuizCount else {
            return
        }

        guard userDefaults.string(forKey: Keys.lastRequestedVersion) != appVersion else {
            return
        }

        userDefaults.set(appVersion, forKey: Keys.lastRequestedVersion)
        requestReview(in: windowScene)
    }

    @MainActor
    private func requestReview(in windowScene: UIWindowScene) {
        AppStore.requestReview(in: windowScene)
    }

    private func resetCompletedQuizCountIfNeeded(for appVersion: String) {
        guard userDefaults.string(forKey: Keys.completedQuizCountVersion) != appVersion else {
            return
        }

        userDefaults.set(0, forKey: Keys.completedQuizCount)
        userDefaults.set(appVersion, forKey: Keys.completedQuizCountVersion)
    }

    private var currentAppVersion: String {
        let infoDictionary = Bundle.main.infoDictionary
        let shortVersion = infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = infoDictionary?["CFBundleVersion"] as? String

        return [shortVersion, buildVersion]
            .compactMap { $0 }
            .joined(separator: "-")
    }
}

extension AppReviewRequesterImpl: AppReviewRequesting {}
