import SwiftUI

struct QuizOfTheDayScreen: View {
    private let viewModel: QuizOfTheDayViewModel
    private let presenter: QuizOfTheDayPresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title) private var questionSize = 28.0
    @ScaledMetric(relativeTo: .largeTitle) private var scoreSize = 76.0

    init(viewModel: QuizOfTheDayViewModel, presenter: QuizOfTheDayPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Color(.backgroundPrimary).frame(height: 0).id("quizTop")
                    if let errorMessage = viewModel.errorMessage {
                        errorState(errorMessage)
                    } else if viewModel.isQuizCompleted {
                        completion
                            .onAppear { presenter.quizCompletedCardAppeared() }
                    } else if let question = viewModel.currentQuestion {
                        progress
                        questionContent(question)
                        if viewModel.isAnswerSubmitted {
                            explanation(question)
                                .id("quizExplanation")
                                .transition(.opacity)
                        }
                    } else {
                        PerfumeBlotterLoadingView(title: L10n.QuizOfTheDay.loading)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: viewModel.isAnswerSubmitted)
            }
            .onChange(of: viewModel.currentQuestionIndex) { _, _ in
                scroll(proxy, to: "quizTop")
            }
            .onChange(of: viewModel.isQuizCompleted) { _, completed in
                if completed { scroll(proxy, to: "quizTop") }
            }
            .onChange(of: viewModel.isAnswerSubmitted) { _, submitted in
                if submitted { scroll(proxy, to: "quizExplanation") }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if viewModel.currentQuestion != nil, !viewModel.isQuizCompleted, viewModel.errorMessage == nil {
                PerfumePrimaryButton(title: viewModel.primaryActionTitle, action: handlePrimaryAction)
                    .disabled(!viewModel.canPerformPrimaryAction)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(.backgroundPrimary))
            }
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .foregroundStyle(Color(.textPrimary))
        .navigationBarTitleDisplayMode(.inline)
        .task { await presenter.onAppear() }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(viewModel.questionProgressTitle.uppercased())
                    .tracking(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.progressPercentText).monospacedDigit()
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(Color(.descriptionText))
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(.textPrimary).opacity(0.08))
                    Rectangle()
                        .fill(Color(.textPrimary))
                        .frame(width: geometry.size.width * viewModel.progressValue)
                }
            }
            .frame(height: 2)
            .accessibilityHidden(true)
        }
    }

    private func questionContent(_ question: QuizOfTheDayQuestion) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            if viewModel.currentQuestionIndex == 0, !dynamicTypeSize.isAccessibilitySize {
                Image(.quizStudioPhoto)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
            }
            Text(question.question)
                .font(.system(size: questionSize, weight: .medium))
                .tracking(-0.7)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(L10n.QuizOfTheDay.selectOneAnswer)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))

            VStack(spacing: 10) {
                ForEach(question.answers, id: \.id) { answer in
                    answerRow(answer)
                }
            }
        }
    }

    private func answerRow(_ answer: QuizOfTheDayAnswer) -> some View {
        let isSelected = viewModel.isAnswerSelected(answer.id)
        let showsCorrect = viewModel.isAnswerSubmitted && answer.isCorrect
        let isEmphasized = showsCorrect || (isSelected && !viewModel.isAnswerSubmitted)

        return Button {
            presenter.selectAnswer(id: answer.id)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(answer.id.uppercased())
                    .font(.caption.monospaced().weight(.medium))
                    .frame(minWidth: 20)
                Text(answer.text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showsCorrect || isSelected {
                    Image(systemName: viewModel.isAnswerSubmitted && !answer.isCorrect ? "xmark" : "checkmark")
                        .font(.footnote.weight(.medium))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(isEmphasized ? Color(.backgroundPrimary) : Color(.textPrimary))
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isEmphasized ? Color(.textPrimary) : Color(.backgroundPrimary))
            .overlay {
                Rectangle().strokeBorder(
                    isSelected || showsCorrect ? Color(.textPrimary) : Color(.inputBorder),
                    lineWidth: 1
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAnswerSubmitted)
        .accessibilityLabel(viewModel.accessibilityLabel(for: answer))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func explanation(_ question: QuizOfTheDayQuestion) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Image(systemName: viewModel.isSelectedAnswerCorrect ? "checkmark" : "arrow.turn.down.right")
                    .accessibilityHidden(true)
                Text(viewModel.answerResultTitle)
                    .font(.title3.weight(.medium))
                    .accessibilityAddTraits(.isHeader)
            }
            Rectangle().fill(Color(.inputBorder)).frame(height: 1)
            Text(L10n.QuizOfTheDay.explanationTitle.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1)
                .foregroundStyle(Color(.descriptionText))
            Text(question.explanation)
                .font(.body)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.textPrimary).opacity(0.035))
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(L10n.QuizOfTheDay.completedEyebrow.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1.2)
                .foregroundStyle(Color(.descriptionText))
            Text(viewModel.scoreSummary)
                .font(.system(size: scoreSize, weight: .light))
                .tracking(-3)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .accessibilityLabel(viewModel.scoreAccessibilityLabel)
            Text(L10n.QuizOfTheDay.completedTitle)
                .font(.system(size: questionSize, weight: .medium))
                .tracking(-0.7)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.QuizOfTheDay.completedSubtitle)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(5)

            if !dynamicTypeSize.isAccessibilitySize {
                Image(.quizStudioPhoto)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
            }

            Rectangle().fill(Color(.inputBorder)).frame(height: 1)
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 22))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 28))
            layout {
                statistic(title: L10n.QuizOfTheDay.scoreToday, value: String(viewModel.scoreToday))
                statistic(title: L10n.QuizOfTheDay.streakDays, value: String(viewModel.streakDays))
            }
            Text(L10n.QuizOfTheDay.scoreHint)
                .font(.footnote)
                .foregroundStyle(Color(.descriptionText))
        }
    }

    private func statistic(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(Color(.descriptionText))
            Text(value).font(.largeTitle.weight(.light)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func errorState(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(message).font(.body).lineSpacing(4)
            PerfumePrimaryButton(title: L10n.QuizOfTheDay.retryButton) {
                Task { await presenter.onAppear() }
            }
        }
        .padding(.vertical, 40)
    }

    private func handlePrimaryAction() {
        if viewModel.canFinishQuiz {
            presenter.finishQuiz()
        } else if viewModel.isAnswerSubmitted {
            presenter.goToNextQuestion()
        } else {
            presenter.submitAnswer()
            if viewModel.isAnswerSubmitted {
                AccessibilityNotification.Announcement(viewModel.answerResultTitle).post()
            }
        }
    }

    private func scroll(_ proxy: ScrollViewProxy, to anchor: String) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            proxy.scrollTo(anchor, anchor: .top)
        }
    }
}
