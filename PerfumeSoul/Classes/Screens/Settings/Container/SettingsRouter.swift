//
//  SettingsRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit
import StoreKit

protocol SettingsRouter {
    func showSendFeedback()
    func openSystemSettings()
    func requestAppReview()
}

final class SettingsRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension SettingsRouterImpl: SettingsRouter {
    func showSendFeedback() {
        navigationController?.pushViewController(
            SendFeedbackModule.build(navigationController: navigationController),
            animated: true
        )
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }

    func requestAppReview() {
        guard let windowScene = navigationController?.view.window?.windowScene else {
            return
        }

        SKStoreReviewController.requestReview(in: windowScene)
    }
}
