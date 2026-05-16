//
//  SendFeedbackPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

protocol SendFeedbackPresenter {
    func sendFeedbackButtonTapped()
}

final class SendFeedbackPresenterImpl {
    private let viewModel: SendFeedbackViewModel
    private let router: SendFeedbackRouter

    init(
        viewModel: SendFeedbackViewModel,
        router: SendFeedbackRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension SendFeedbackPresenterImpl: SendFeedbackPresenter {
    func sendFeedbackButtonTapped() {
        router.presentMailComposer(
            email: viewModel.developerEmail,
            subject: "PerfumeSoul Feedback"
        )
    }
}
