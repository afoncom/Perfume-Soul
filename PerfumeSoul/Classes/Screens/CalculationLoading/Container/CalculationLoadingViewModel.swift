//
//  CalculationLoadingViewModel.swift
//  PerfumeSoul
//

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
    var progress = 0.0
    var activeStage: CalculationLoadingStage = .birthData
    var failure: CalculationLoadingFailure?
}
