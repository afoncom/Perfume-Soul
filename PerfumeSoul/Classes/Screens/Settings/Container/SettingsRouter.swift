//
//  SettingsRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol SettingsRouter {
    func showSendFeedback()
    func openSystemSettings()
    func requestAppReview()
}

final class SettingsRouterImpl {
    private weak var navigationController: UINavigationController?
    private let appReviewRequester: AppReviewRequester

    init(
        navigationController: UINavigationController?,
        appReviewRequester: AppReviewRequester = AppReviewRequester()
    ) {
        self.navigationController = navigationController
        self.appReviewRequester = appReviewRequester
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

        appReviewRequester.requestReview(in: windowScene)
    }
}
