//
//  CalculationLoadingScreen.swift
//  PerfumeSoul
//

import SwiftUI

struct CalculationLoadingScreen: View {
    @Bindable private var viewModel: CalculationLoadingViewModel
    private let presenter: CalculationLoadingPresenter

    init(
        viewModel: CalculationLoadingViewModel,
        presenter: CalculationLoadingPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(.calculationLoadingBackground)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let failure = viewModel.failure {
                        makeFailureView(failure)
                    } else {
                        makeLoadingView()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 48)
                .padding(.bottom, 180)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task(id: viewModel.retryAttempt) {
            await presenter.onAppear()
        }
    }
}

extension CalculationLoadingScreen {
    private func makeLoadingView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.CalculationLoading.title)
                .font(.system(size: 40, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))
                .fixedSize(horizontal: false, vertical: true)

            makeProgressRing()
                .frame(maxWidth: .infinity)
                .padding(.top, 58)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(CalculationLoadingStage.allCases, id: \.self) { stage in
                    makeStageRow(stage)
                }
            }
            .padding(.top, 42)
        }
    }

    private func makeProgressRing() -> some View {
        ZStack {
            Circle()
                .stroke(Color(.inputBorder), lineWidth: 3)

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(Color(.textPrimary), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(viewModel.progress.formatted(.percent.precision(.fractionLength(0))))
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))
        }
        .frame(width: 156, height: 156)
        .animation(.easeInOut(duration: 0.15), value: viewModel.progress)
        .accessibilityLabel(L10n.CalculationLoading.title)
        .accessibilityValue(viewModel.progress.formatted(.percent.precision(.fractionLength(0))))
    }

    private func makeStageRow(_ stage: CalculationLoadingStage) -> some View {
        let isComplete = viewModel.progress >= 1 || stage.rawValue < viewModel.activeStage.rawValue
        let isActive = stage == viewModel.activeStage && !isComplete

        return HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                makeStageIndicator(isComplete: isComplete, isActive: isActive)

                if stage != .saveProfile {
                    Rectangle()
                        .fill(Color(.inputBorder))
                        .frame(width: 1, height: 44)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title(for: stage))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)

                if isComplete || isActive {
                    Text(subtitle(for: stage, isComplete: isComplete))
                        .font(.subheadline)
                        .foregroundStyle(Color(.descriptionText))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 2)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeStage)
    }

    @ViewBuilder
    private func makeStageIndicator(isComplete: Bool, isActive: Bool) -> some View {
        if isComplete {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.backgroundPrimary))
                .frame(width: 34, height: 34)
                .background(Color(.textPrimary), in: Circle())
                .accessibilityHidden(true)
        } else if isActive {
            ZStack {
                Circle()
                    .stroke(Color(.textPrimary), lineWidth: 1.5)
                Circle()
                    .fill(Color(.textPrimary))
                    .frame(width: 10, height: 10)
            }
            .frame(width: 34, height: 34)
            .accessibilityHidden(true)
        } else {
            Circle()
                .stroke(Color(.descriptionText), lineWidth: 1.5)
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)
        }
    }

    private func title(for stage: CalculationLoadingStage) -> String {
        switch stage {
        case .birthData:
            L10n.CalculationLoading.stageBirthDataTitle
        case .natalChart:
            L10n.CalculationLoading.stageNatalChartTitle
        case .saveProfile:
            L10n.CalculationLoading.stageSaveProfileTitle
        }
    }

    private func subtitle(for stage: CalculationLoadingStage, isComplete: Bool) -> String {
        switch stage {
        case .birthData:
            isComplete
                ? L10n.CalculationLoading.stageBirthDataComplete
                : L10n.CalculationLoading.stageBirthDataActive
        case .natalChart:
            isComplete
                ? L10n.CalculationLoading.stageNatalChartComplete
                : L10n.CalculationLoading.stageNatalChartActive
        case .saveProfile:
            isComplete
                ? L10n.CalculationLoading.stageSaveProfileComplete
                : L10n.CalculationLoading.stageSaveProfileActive
        }
    }

    private func makeFailureView(_ failure: CalculationLoadingFailure) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(failureTitle(failure))
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))

            Text(failureMessage(failure))
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .fixedSize(horizontal: false, vertical: true)

            if failure != .invalidBirthData {
                Button {
                    presenter.retryButtonTapped()
                } label: {
                    Text(L10n.ProfileDescription.retryButton)
                        .font(.headline)
                        .foregroundStyle(Color(.backgroundPrimary))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.textPrimary), in: Capsule())
                }
                .padding(.top, 24)
            }

            Button {
                presenter.editBirthDataTapped()
            } label: {
                Text(L10n.CalculationLoading.editBirthDataButton)
                    .font(.body)
                    .foregroundStyle(Color(.textPrimary))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    private func failureTitle(_ failure: CalculationLoadingFailure) -> String {
        switch failure {
        case .offline:
            L10n.CalculationLoading.offlineTitle
        case .invalidBirthData:
            L10n.CalculationLoading.invalidBirthDataTitle
        case .failed:
            L10n.CalculationLoading.failedTitle
        }
    }

    private func failureMessage(_ failure: CalculationLoadingFailure) -> String {
        switch failure {
        case .offline:
            L10n.CalculationLoading.offlineMessage
        case .invalidBirthData:
            L10n.CalculationLoading.invalidBirthDataMessage
        case .failed:
            L10n.CalculationLoading.failedMessage
        }
    }
}
