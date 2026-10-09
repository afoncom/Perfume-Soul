//
//  CalculationLoadingViewModel.swift
//  PerfumeSoul
//

import Foundation
import Observation

enum CalculationLoadingStage: Int, CaseIterable {
    case birthData
    case natalChart
    case saveProfile
}

enum CalculationLoadingFailure {
    case offline
    case invalidBirthData
    case failed
}

@Observable final class CalculationLoadingViewModel {
    var hasStartedLoading = false
    var retryAttempt = 0
    var progress = 0.0
    var activeStage: CalculationLoadingStage = .birthData
    var failure: CalculationLoadingFailure?

    var progressText: String {
        progress.formatted(.percent.precision(.fractionLength(0)))
    }

    func isStageComplete(_ stage: CalculationLoadingStage) -> Bool {
        progress >= 1 || stage.rawValue < activeStage.rawValue
    }

    func isStageActive(_ stage: CalculationLoadingStage) -> Bool {
        stage == activeStage && !isStageComplete(stage)
    }
}

extension CalculationLoadingViewModel {
    func stageTitle(for stage: CalculationLoadingStage) -> String {
        switch stage {
        case .birthData:
            L10n.CalculationLoading.stageBirthDataTitle
        case .natalChart:
            L10n.CalculationLoading.stageNatalChartTitle
        case .saveProfile:
            L10n.CalculationLoading.stageSaveProfileTitle
        }
    }

    func stageSubtitle(for stage: CalculationLoadingStage, isComplete: Bool) -> String {
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

    func failureTitle(_ failure: CalculationLoadingFailure) -> String {
        switch failure {
        case .offline:
            L10n.CalculationLoading.offlineTitle
        case .invalidBirthData:
            L10n.CalculationLoading.invalidBirthDataTitle
        case .failed:
            L10n.CalculationLoading.failedTitle
        }
    }

    func failureMessage(_ failure: CalculationLoadingFailure) -> String {
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
