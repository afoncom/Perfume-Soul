//
//  SendFeedbackScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import SwiftUI

struct SendFeedbackScreen: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: SendFeedbackViewModel
    private let presenter: SendFeedbackPresenter

    init(
        viewModel: SendFeedbackViewModel,
        presenter: SendFeedbackPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                makeHeaderView()
                makeEmailCard()

                if viewModel.canSendMail {
                    makeSendButton()
                } else {
                    makeFallbackCard()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .task {
            presenter.onAppear()
        }
        .toolbar(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color(.textPrimary))
                }
            }
        }
    }
}

private extension SendFeedbackScreen {
    func makeHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.SendFeedback.title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))

            Text(L10n.SendFeedback.subtitle)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func makeEmailCard() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.SendFeedback.emailTitle)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))

            Text(viewModel.developerEmail)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(Color(.pinkButton))

            Text(L10n.SendFeedback.emailSubtitle)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    func makeFallbackCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundStyle(Color(.zodiacPurple))

            Text(L10n.SendFeedback.mailUnavailable)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.purpleTable))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.tableBorder), lineWidth: 1)
        )
    }

    func makeSendButton() -> some View {
        Button {
            presenter.sendFeedbackButtonTapped()
        } label: {
            Text(L10n.SendFeedback.button)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.buttonShine),
                            Color(.pinkButton)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .background(Color(.surfaceHighlight))
    }
}
