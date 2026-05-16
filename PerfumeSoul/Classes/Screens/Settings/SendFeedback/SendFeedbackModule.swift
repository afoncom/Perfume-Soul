//
//  SendFeedbackModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import SwiftUI

final class SendFeedbackModule {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let mailService = MailServiceImpl()
        let viewModel = SendFeedbackViewModel(
            developerEmail: "afon.com12@gmail.com",
            canSendMail: mailService.canSendMail()
        )
        let router = SendFeedbackRouterImpl(navigationController: navigationController)
        let presenter = SendFeedbackPresenterImpl(
            viewModel: viewModel,
            router: router
        )

        let view = SendFeedbackScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.sendFeedback

        return hostingController
    }
}
