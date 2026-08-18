//
//  QuizOfTheDayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct QuizOfTheDayScreen: View {
    private let viewModel: QuizOfTheDayViewModel
    private let presenter: QuizOfTheDayPresenter
    @State private var isShowingExplanation = false
    @ScaledMetric(relativeTo: .body) private var explanationDetentHeight = 280.0

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
                makeProgressCard()
                if let errorMessage = viewModel.errorMessage {
                    makeErrorCard(message: errorMessage)
                } else if viewModel.isQuizCompleted {
                    makeQuizCompletedCard()
                } else if let currentQuestion = viewModel.currentQuestion {
                    makeQuestionCard(question: currentQuestion)
                    if viewModel.isAnswerSubmitted {
                        makeAnswerResultPill(isCorrect: viewModel.isSelectedAnswerCorrect)
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
            .animation(.snappy, value: viewModel.isAnswerSubmitted)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .task {
            await presenter.onAppear()
        }
        .sheet(isPresented: $isShowingExplanation) {
            makeExplanationSheet()
                .presentationDetents([.height(explanationDetentHeight), .medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

extension QuizOfTheDayScreen {
    func makeErrorCard(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await presenter.onAppear()
                }
            } label: {
                Text(L10n.QuizOfTheDay.retryButton)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.textOnAccent))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.pinkButton))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 10, x: 0, y: 4)
    }

    func makeProgressCard() -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                makeStatItem(
                    icon: "trophy",
                    iconColor: Color(.pinkButton),
                    title: L10n.QuizOfTheDay.scoreToday,
                    value: "\(viewModel.scoreToday)",
                    trailingValue: "/ \(viewModel.totalQuestions)"
                )

                Spacer(minLength: 8)

                makeStatItem(
                    icon: "flame.fill",
                    iconColor: Color(.pinkButton),
                    title: L10n.QuizOfTheDay.streakDays,
                    value: "\(viewModel.streakDays)",
                    trailingValue: L10n.QuizOfTheDay.daySuffix,
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
                            .frame(width: proxy.size.width * .init(viewModel.progressValue), height: 10)
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
                        isCorrect: answer.isCorrect,
                        isSubmitted: viewModel.isAnswerSubmitted
                    ) {
                        presenter.selectAnswer(id: answer.id)
                    }
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
        isCorrect: Bool,
        isSubmitted: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        let isRevealedCorrectAnswer = isSubmitted && isCorrect
        let accentColor = isRevealedCorrectAnswer ? Color(.zodiacMint) : Color(.pinkButton)

        return Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected || isRevealedCorrectAnswer ? accentColor : Color(.placeholderSoft))
                        .frame(width: 48, height: 48)

                    Text(letter)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected || isRevealedCorrectAnswer ? Color(.textPrimary) : Color(.textSecondary))
                }

                Text(title)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.textPrimary))

                if isSubmitted, isCorrect {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color(.textPrimary))
                        .accessibilityHidden(true)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected || isRevealedCorrectAnswer ? accentColor : Color(.cardBorder),
                        lineWidth: isSelected || isRevealedCorrectAnswer ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isSubmitted)
        .accessibilityLabel(
            makeAnswerLabel(
                letter: letter,
                title: title,
                isSelected: isSelected,
                isCorrect: isCorrect,
                isSubmitted: isSubmitted
            )
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func makeAnswerLabel(
        letter: String,
        title: String,
        isSelected: Bool,
        isCorrect: Bool,
        isSubmitted: Bool
    ) -> String {
        var components = ["\(letter), \(title)"]

        if isSelected {
            components.append(L10n.QuizOfTheDay.selectedAnswerAccessibility)
        }

        if isSubmitted, isCorrect {
            components.append(L10n.QuizOfTheDay.correctAnswerAccessibility)
        }

        return components.joined(separator: ", ")
    }

    func makeAnswerResultPill(isCorrect: Bool) -> some View {
        let accentColor = isCorrect ? Color(.zodiacMint) : Color(.pinkButton)

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 38, height: 38)

                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(.textPrimary))
            }

            Text(isCorrect ? L10n.QuizOfTheDay.correctResult : L10n.QuizOfTheDay.incorrectResult)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 0)

            Button {
                isShowingExplanation = true
            } label: {
                HStack(spacing: 6) {
                    Text(L10n.QuizOfTheDay.explanationButton)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))

                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color(.textPrimary))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(accentColor.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(accentColor.opacity(0.16), lineWidth: 1)
        )
        .transition(.scale(scale: 0.96).combined(with: .opacity))
    }

    func makeExplanationSheet() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            if let currentQuestion = viewModel.currentQuestion {
                let isCorrect = viewModel.isSelectedAnswerCorrect
                let accentColor = isCorrect ? Color(.zodiacMint) : Color(.pinkButton)

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 46, height: 46)

                        Image(systemName: isCorrect ? "checkmark" : "xmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color(.textPrimary))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.QuizOfTheDay.explanationTitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color(.textSecondary))

                        Text(isCorrect ? L10n.QuizOfTheDay.correctResult : L10n.QuizOfTheDay.incorrectResult)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color(.textPrimary))
                    }
                }

                ScrollView(.vertical, showsIndicators: false) {
                    Text(currentQuestion.explanation)
                        .font(.body)
                        .foregroundStyle(Color(.descriptionText))
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            makeCloseExplanationButton()
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 18)
        .background(Color(.backgroundPrimary))
    }

    private func makeCloseExplanationButton() -> some View {
        Button {
            isShowingExplanation = false
        } label: {
            Text(L10n.QuizOfTheDay.closeExplanationButton)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color(.pinkButton))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    func makeQuizCompletedCard() -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color(.surfaceOverlay))
                    .frame(width: 72, height: 72)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Color(.pinkButton))
            }

            VStack(spacing: 10) {
                Text(L10n.QuizOfTheDay.completedTitle)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.titleText))
                    .multilineTextAlignment(.center)

                Text(L10n.QuizOfTheDay.completedSubtitle)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(.descriptionText))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 10, x: 0, y: 4)
    }

    func makeBottomControls() -> some View {
        VStack(spacing: 16) {
            if !viewModel.isQuizCompleted {
                Button(action: handlePrimaryAction) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 21, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.textOnAccent))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(.pinkButton))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canPerformPrimaryAction)
                .opacity(canPerformPrimaryAction ? 1 : 0.55)
            }
        }
    }

    var canPerformPrimaryAction: Bool {
        if viewModel.isQuizCompleted {
            return false
        }
        if viewModel.canFinishQuiz {
            return true
        }
        return viewModel.isAnswerSubmitted ? viewModel.canGoToNextQuestion : viewModel.canSubmitAnswer
    }

    var primaryButtonTitle: String {
        if viewModel.canFinishQuiz {
            return L10n.QuizOfTheDay.finishQuiz
        }
        return viewModel.isAnswerSubmitted ? L10n.QuizOfTheDay.nextQuestion : L10n.QuizOfTheDay.submitAnswer
    }

    func handlePrimaryAction() {
        if viewModel.canFinishQuiz {
            presenter.finishQuiz()
        } else if viewModel.isAnswerSubmitted {
            presenter.goToNextQuestion()
        } else {
            presenter.submitAnswer()
        }
    }
}
