//
//  SendFeedbackScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import SwiftUI

struct SendFeedbackScreen: View {
    private let viewModel: SendFeedbackViewModel
    private let presenter: SendFeedbackPresenter

    init(viewModel: SendFeedbackViewModel, presenter: SendFeedbackPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.SendFeedback.title)
                        .font(.largeTitle.weight(.medium))
                        .tracking(-1)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(L10n.SendFeedback.subtitle)
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundStyle(Color(.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.SendFeedback.emailTitle.uppercased())
                        .font(.caption.weight(.medium))
                        .tracking(1)
                        .foregroundStyle(Color(.textSecondary))
                    Text(viewModel.developerEmail)
                        .font(.body.weight(.medium))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                    ShareLink(item: viewModel.developerEmail) {
                        Label(String(localized: "sendFeedback.shareEmail"), systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.placeholderSoft))

                if viewModel.canSendMail {
                    PerfumePrimaryButton(title: L10n.SendFeedback.button) {
                        presenter.sendFeedbackButtonTapped()
                    }
                } else {
                    Text(L10n.SendFeedback.mailUnavailable)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .tint(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .task { presenter.onAppear() }
    }
}
