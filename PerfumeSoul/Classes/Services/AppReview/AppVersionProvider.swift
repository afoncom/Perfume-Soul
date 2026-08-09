//
//  AppVersionProvider.swift
//  PerfumeSoul
//
//  Created by Codex on 05.08.2026.
//

import Foundation

protocol AppVersionProvider {
    func currentAppVersion() -> String?
}

final class AppVersionProviderImpl {}

extension AppVersionProviderImpl: AppVersionProvider {
    func currentAppVersion() -> String? {
        guard let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }

        let trimmedVersion = shortVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedVersion.isEmpty ? nil : trimmedVersion
    }
}
