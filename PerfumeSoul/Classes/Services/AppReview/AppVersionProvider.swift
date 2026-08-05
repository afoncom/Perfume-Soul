//
//  AppVersionProvider.swift
//  PerfumeSoul
//
//  Created by Codex on 05.08.2026.
//

import Foundation

protocol AppVersionProvider {
    func currentAppVersion() -> String
}

final class AppVersionProviderImpl {}

extension AppVersionProviderImpl: AppVersionProvider {
    func currentAppVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        let shortVersion = infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = infoDictionary?["CFBundleVersion"] as? String

        return [shortVersion, buildVersion]
            .compactMap { $0 }
            .joined(separator: "-")
    }
}
