//
//  CalculationLoadingScreen.swift
//  PerfumeSoul
//

import SwiftUI

struct CalculationLoadingScreen: View {
    @Bindable private var viewModel: CalculationLoadingViewModel
    private let presenter: CalculationLoadingPresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 32

    init(viewModel: CalculationLoadingViewModel, presenter: CalculationLoadingPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PerfumeFlowHeader(section: L10n.PerfumeFlow.loadingSection, step: 2)
                    .padding(.bottom, 32)

                if let failure = viewModel.failure {
                    makeFailureView(failure)
                } else {
                    makeLoadingView()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
        .background(Color(.backgroundPrimary))
        .preferredColorScheme(.light)
        .task(id: viewModel.retryAttempt) {
            await presenter.onAppear()
        }
    }
}

extension CalculationLoadingScreen {
    private func makeLoadingView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.CalculationLoading.title)
                .font(.system(size: headingSize, weight: .semibold))
                .tracking(-0.8)
                .foregroundStyle(Color(.textPrimary))
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.PerfumeFlow.loadingSubtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
                .padding(.top, 12)
                .padding(.bottom, 28)

            PerfumeStudioBanner(
                title: viewModel.progressText,
                caption: L10n.PerfumeFlow.loadingCaption,
                showsProgress: true
            )
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: viewModel.progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.CalculationLoading.title)
            .accessibilityValue(viewModel.progressText)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.textPrimary).opacity(0.08))

                    Rectangle()
                        .fill(Color(.textPrimary))
                        .frame(width: geometry.size.width * viewModel.progress)
                }
            }
            .frame(height: 3)
            .animation(reduceMotion ? nil : .linear(duration: 0.2), value: viewModel.progress)
            .accessibilityHidden(true)
            .padding(.bottom, 24)

            VStack(spacing: 0) {
                ForEach(CalculationLoadingStage.allCases, id: \.self) { stage in
                    makeStageRow(stage)
                }
            }
        }
    }

    private func makeStageRow(_ stage: CalculationLoadingStage) -> some View {
        let isComplete = viewModel.isStageComplete(stage)
        let isActive = viewModel.isStageActive(stage)

        return VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Group {
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.semibold))
                    } else {
                        Text(String(format: "%02d", stage.rawValue + 1))
                            .font(.caption.monospacedDigit())
                    }
                }
                .foregroundStyle(isComplete ? Color(.backgroundPrimary) : Color(.textPrimary))
                .frame(width: 32, height: 32)
                .background(Color(.textPrimary).opacity(isComplete ? 1 : 0.04))
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.stageTitle(for: stage))
                        .font(.subheadline.weight(isActive ? .semibold : .regular))
                        .foregroundStyle(Color(.textPrimary))

                    if isActive || isComplete {
                        Text(viewModel.stageSubtitle(for: stage, isComplete: isComplete))
                            .font(.caption)
                            .foregroundStyle(Color(.descriptionText))
                            .transition(.opacity)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 17)

            Rectangle()
                .fill(Color(.inputBorder))
                .frame(height: 1)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.activeStage)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.progress >= 1)
    }

    private func makeFailureView(_ failure: CalculationLoadingFailure) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(viewModel.failureTitle(failure))
                .font(.system(size: headingSize, weight: .semibold))
                .foregroundStyle(Color(.textPrimary))

            Text(viewModel.failureMessage(failure))
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)

            if failure != .invalidBirthData {
                PerfumePrimaryButton(title: L10n.ProfileDescription.retryButton) {
                    presenter.retryButtonTapped()
                }
                .padding(.top, 18)
            }

            Button {
                presenter.editBirthDataTapped()
            } label: {
                Text(L10n.CalculationLoading.editBirthDataButton)
                    .font(.body)
                    .foregroundStyle(Color(.textPrimary))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .overlay {
                        Rectangle().stroke(Color(.inputBorder), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
    }
}
