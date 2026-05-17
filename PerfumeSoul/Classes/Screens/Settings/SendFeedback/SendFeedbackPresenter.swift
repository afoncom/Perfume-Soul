//
//  SendFeedbackPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

protocol SendFeedbackPresenter {
    func onAppear()
    func sendFeedbackButtonTapped()
}

final class SendFeedbackPresenterImpl {
    private let viewModel: SendFeedbackViewModel
    private let router: SendFeedbackRouter
    private let mailService: MailService

    init(
        viewModel: SendFeedbackViewModel,
        router: SendFeedbackRouter,
        mailService: MailService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.mailService = mailService
    }
}

extension SendFeedbackPresenterImpl: SendFeedbackPresenter {
    func onAppear() {
        viewModel.canSendMail = mailService.canSendMail()
    }

    func sendFeedbackButtonTapped() {
        router.presentMailComposer(
            email: viewModel.developerEmail,
            subject: "PerfumeSoul Feedback"
        )
    }
}
