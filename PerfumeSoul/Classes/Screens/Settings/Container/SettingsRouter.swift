//
//  SettingsRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol SettingsRouter {
    var isPrivacyPolicyAvailable: Bool { get }

    func showSendFeedback()
    func openPrivacyPolicy()
    func openSystemSettings()
}

final class SettingsRouterImpl {
    private weak var navigationController: UINavigationController?
    // TODO: Replace with the hosted Privacy Policy URL before App Store submission.
    private let privacyPolicyURL: URL? = nil

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension SettingsRouterImpl: SettingsRouter {
    var isPrivacyPolicyAvailable: Bool {
        privacyPolicyURL != nil
    }

    func showSendFeedback() {
        navigationController?.pushViewController(
            SendFeedbackModule.build(navigationController: navigationController),
            animated: true
        )
    }

    func openPrivacyPolicy() {
        guard let privacyPolicyURL else {
            return
        }

        UIApplication.shared.open(privacyPolicyURL)
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
