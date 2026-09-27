//
//  CalculationLoadingPresenter.swift
//  PerfumeSoul
//

import Foundation

@MainActor
protocol CalculationLoadingPresenter {
    func onAppear() async
    func retryButtonTapped() async
    func editBirthDataTapped()
}

final class CalculationLoadingPresenterImpl {
    private let viewModel: CalculationLoadingViewModel
    private let router: CalculationLoadingRouter
    private let profileService: ProfileService
    private let profileCalculationService: ProfileCalculationService

    init(
        viewModel: CalculationLoadingViewModel,
        router: CalculationLoadingRouter,
        profileService: ProfileService,
        profileCalculationService: ProfileCalculationService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
        self.profileCalculationService = profileCalculationService
    }
}

extension CalculationLoadingPresenterImpl: CalculationLoadingPresenter {
    func onAppear() async {
        guard !viewModel.hasStartedLoading else {
            return
        }

        viewModel.hasStartedLoading = true
        await loadProfile()
    }

    func retryButtonTapped() async {
        guard viewModel.failure != nil else {
            return
        }

        await loadProfile()
    }

    func editBirthDataTapped() {
        router.showCalculationScreen()
    }

    @MainActor
    private func loadProfile() async {
        viewModel.failure = nil
        viewModel.progress = 0
        viewModel.activeStage = .birthData

        let clock = ContinuousClock()
        let started = clock.now
        let progressTask = Task { @MainActor [viewModel] in
            for tick in 1...40 {
                do {
                    try await Task.sleep(for: .milliseconds(150))
                } catch {
                    return
                }

                viewModel.progress = Double(tick) * 0.02
                if tick >= 8 {
                    viewModel.activeStage = .natalChart
                }
            }
        }
        defer {
            progressTask.cancel()
        }

        guard let profile = await profileService.fetchProfile(), !Task.isCancelled else {
            if !Task.isCancelled {
                viewModel.failure = .failed
            }
            return
        }

        do {
            let calculation = try await profileCalculationService.calculate(profile: profile)
            let elapsed = clock.now - started
            if elapsed < .seconds(6) {
                try await Task.sleep(for: .seconds(6) - elapsed)
            }

            progressTask.cancel()
            viewModel.progress = max(viewModel.progress, 0.82)
            viewModel.activeStage = .saveProfile
            await profileService.replaceProfile(profile.withProfileCalculation(calculation))

            let remaining = .seconds(8.0) - (clock.now - started)
            if remaining > .zero {
                for step in 1...12 {
                    try await Task.sleep(for: remaining / 12)
                    viewModel.progress = 0.82 + Double(step) * 0.16 / 12
                }
            }

            guard !Task.isCancelled else {
                return
            }

            viewModel.progress = 1
            try await Task.sleep(for: .milliseconds(350))
            router.showProfileDescription()
        } catch is CancellationError {
            return
        } catch is ProfileCalculationError {
            viewModel.failure = .invalidBirthData
        } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            viewModel.failure = .offline
        } catch {
            if !Task.isCancelled {
                viewModel.failure = .failed
            }
        }
    }
}
