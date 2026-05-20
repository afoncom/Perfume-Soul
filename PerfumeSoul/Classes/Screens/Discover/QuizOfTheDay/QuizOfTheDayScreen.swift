//
//  QuizOfTheDayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct QuizOfTheDayScreen: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: QuizOfTheDayViewModel
    private let presenter: QuizOfTheDayPresenter

    init(
        viewModel: QuizOfTheDayViewModel,
        presenter: QuizOfTheDayPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 22) {
                makeTopBar()
                makeProgressCard()
                if let currentQuestion = viewModel.currentQuestion {
                    makeQuestionCard(question: currentQuestion)
                    if viewModel.hasSelectedAnswer {
                        makeExplanationCard(
                            explanation: currentQuestion.explanation,
                            isCorrect: viewModel.isSelectedAnswerCorrect
                        )
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                }
                makeBottomControls()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .task {
            await presenter.onAppear()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension QuizOfTheDayScreen {
    func makeTopBar() -> some View {
        HStack(alignment: .center) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.surfacePrimary))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color(.textPrimary))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text(L10n.QuizOfTheDay.title)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.titleText))
                .multilineTextAlignment(.center)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    func makeProgressCard() -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                makeStatItem(
                    icon: "trophy",
                    iconColor: Color(.pinkButton),
                    title: L10n.QuizOfTheDay.scoreToday,
                    value: "8",
                    trailingValue: "/ 15"
                )

                
                Spacer(minLength: 8)

                makeStatItem(
                    icon: "flame.fill",
                    iconColor: Color(.pinkButton),
                    title: L10n.QuizOfTheDay.streakDays,
                    value: "3 дня",
                    trailingValue: nil
                )
            }

            Divider()
                .overlay(Color(.cardBorder))

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Вопрос \(viewModel.currentQuestionNumber) из \(viewModel.totalQuestions)")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.textPrimary))

                    Spacer()

                    Text(viewModel.progressPercentText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.textSecondary))
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.placeholderSoft))
                            .frame(height: 10)

                        Capsule()
                            .fill(Color(.pinkButton))
                            .frame(width: proxy.size.width * viewModel.progressValue, height: 10)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 10, x: 0, y: 4)
    }

    func makeStatItem(
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        trailingValue: String?
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.surfaceOverlay))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textSecondary))

                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(trailingValue == nil ? Color(.textPrimary) : Color(.pinkButton))

                    if let trailingValue {
                        Text(trailingValue)
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(.textSecondary))
                    }
                }
            }
        }
    }

    func makeQuestionCard(question: QuizOfTheDayQuestion) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(question.question)
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                    .multilineTextAlignment(.center)

                Text(L10n.QuizOfTheDay.selectOneAnswer)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            VStack(spacing: 14) {
                ForEach(question.answers, id: \.id) { answer in
                    makeAnswerRow(
                        letter: answer.id,
                        title: answer.text,
                        isSelected: viewModel.isAnswerSelected(answer.id),
                        onTap: {
                            viewModel.selectAnswer(id: answer.id)
                        }
                    )
                }
            }
        }
        .padding(18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 10, x: 0, y: 4)
    }

    func makeAnswerRow(
        letter: String,
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(.pinkButton) : Color(.placeholderSoft))
                        .frame(width: 48, height: 48)

                    Text(letter)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected ? Color(.textOnAccent) : Color(.textSecondary))
                }

                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textPrimary))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? Color(.pinkButton) : Color(.cardBorder), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    func makeExplanationCard(explanation: String, isCorrect: Bool) -> some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(isCorrect ? Color(.zodiacMint) : Color(.pinkButton))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: isCorrect ? "checkmark" : "xmark")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color(.surfacePrimary))
                        }

                    Text(isCorrect ? L10n.QuizOfTheDay.correctResult : L10n.QuizOfTheDay.incorrectResult)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(isCorrect ? Color(.zodiacMint) : Color(.pinkButton))
                }

                Text(explanation)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.placeholderSoft))
                .frame(width: 120, height: 120)
                .overlay {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color(.zodiacMint))
                }
        }
        .padding(18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 10, x: 0, y: 4)
    }

    func makeBottomControls() -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                makeArrowButton(systemName: "arrow.left")

                Button(action: { }) {
                    Text(L10n.QuizOfTheDay.nextQuestion)
                        .font(.system(size: 21, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.textOnAccent))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
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
                .buttonStyle(.plain)

                makeArrowButton(systemName: "arrow.right")
            }

            HStack(spacing: 8) {
                Image(systemName: "lightbulb")
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))

                Text(L10n.QuizOfTheDay.scoreHint)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textSecondary))
            }
        }
    }

    func makeArrowButton(systemName: String) -> some View {
        Button(action: { }) {
            ZStack {
                Circle()
                    .fill(Color(.surfacePrimary))
                    .frame(width: 58, height: 58)

                Image(systemName: systemName)
                    .font(.title3)
                    .foregroundStyle(Color(.pinkButton))
            }
        }
        .buttonStyle(.plain)
    }
}
