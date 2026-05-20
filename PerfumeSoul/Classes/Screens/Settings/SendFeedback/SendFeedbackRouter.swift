//
//  SendFeedbackRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import UIKit
import MessageUI

protocol SendFeedbackRouter {
    func presentMailComposer(email: String, subject: String)
}

final class SendFeedbackRouterImpl: NSObject {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension SendFeedbackRouterImpl: SendFeedbackRouter {
    func presentMailComposer(email: String, subject: String) {
        let composer = MFMailComposeViewController()
        composer.setToRecipients([email])
        composer.setSubject(subject)
        composer.setMessageBody("", isHTML: false)
        composer.mailComposeDelegate = self

        navigationController?.present(composer, animated: true)
    }
}

extension SendFeedbackRouterImpl: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        if let error {
            print("Mail composer error: \(error)")
        }

        switch result {
        case .cancelled:
            print("Mail composer cancelled")
        case .saved:
            print("Mail composer draft saved")
        case .sent:
            print("Mail composer sent")
        case .failed:
            print("Mail composer failed")
        @unknown default:
            print("Mail composer finished with unknown result")
        }

        controller.dismiss(animated: true)
    }
}
