//
//  DailyPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol DailyPerfumePresenter {
    func resolve(profile: Profile?) async
    @MainActor
    func saveCurrentPerfume()
    @MainActor
    func dismissCurrentPerfume()
    func retry() async
    @MainActor
    func perfumeTapped(_ perfume: DailyPerfumeSummary)
}

final class DailyPerfumePresenterImpl {
    private static let candidateLimit = 20

    private let viewModel: DailyPerfumeViewModel
    private let router: DailyPerfumeRouter
    private let service: DailyPerfumeService
    private let stateStorage: DailyPerfumeStateStorage
    private let dayKeyProvider: DailyPerfumeDayKeyProvider
    private let selectionService: DailyPerfumeSelectionService
    private var profile: Profile?

    init(
        viewModel: DailyPerfumeViewModel,
        router: DailyPerfumeRouter,
        service: DailyPerfumeService,
        stateStorage: DailyPerfumeStateStorage,
        dayKeyProvider: DailyPerfumeDayKeyProvider,
        selectionService: DailyPerfumeSelectionService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
        self.stateStorage = stateStorage
        self.dayKeyProvider = dayKeyProvider
        self.selectionService = selectionService
    }
}

extension DailyPerfumePresenterImpl: DailyPerfumePresenter {
    func resolve(profile: Profile?) async {
        self.profile = profile
        await setState(.loading)

        guard
            let profile,
            let profileCalculation = profile.cachedProfileCalculation
        else {
            await setState(.missingProfile)
            return
        }

        let dayKey = dayKeyProvider.todayKey()
        var state = preparedState(
            storedState: stateStorage.loadState(),
            profileCalculationCacheKey: profile.profileCalculationCacheKey,
            dayKey: dayKey
        )

        if let currentPerfume = state.currentPerfume,
           let reaction = state.currentReaction {
            await setState(.content(currentPerfume, reaction))
            return
        }

        do {
            var candidates = try await requestCandidates(
                profileCalculation: profileCalculation,
                state: state
            )

            if candidates.isEmpty, !state.shownPerfumeIDs.isEmpty {
                state.shownPerfumeIDs = []
                candidates = try await requestCandidates(
                    profileCalculation: profileCalculation,
                    state: state
                )
            }

            guard let candidate = selectionService.selectCandidate(from: candidates) else {
                stateStorage.saveState(state)
                await setState(.exhausted)
                return
            }

            let perfume = DailyPerfumeSummary(
                id: candidate.id,
                perfumeName: candidate.perfumeName,
                brandName: candidate.brandName
            )
            state.currentPerfume = perfume
            state.currentReaction = .pending
            appendUnique(perfume.id, to: &state.shownPerfumeIDs)
            state.lastShownBrand = perfume.brandName
            stateStorage.saveState(state)

            await setState(.content(perfume, .pending))
        } catch {
            await setState(.failed)
        }
    }

    @MainActor
    func saveCurrentPerfume() {
        mutateCurrentPerfume(
            { state, perfume in
                guard !state.savedPerfumes.contains(where: { $0.id == perfume.id }) else {
                    return
                }

                state.savedPerfumes.append(perfume)
            },
            reaction: .saved
        )
    }

    @MainActor
    func dismissCurrentPerfume() {
        mutateCurrentPerfume(
            { state, perfume in
                appendUnique(perfume.id, to: &state.dislikedPerfumeIDs)
            },
            reaction: .dismissed
        )
    }

    func retry() async {
        await resolve(profile: profile)
    }

    @MainActor
    func perfumeTapped(_ perfume: DailyPerfumeSummary) {
        router.showPerfumeDetailsScreen(
            perfume: SearchPerfumeItem(id: perfume.id, name: perfume.perfumeName)
        )
    }
}

private extension DailyPerfumePresenterImpl {
    func preparedState(
        storedState: DailyPerfumeState?,
        profileCalculationCacheKey: String?,
        dayKey: String
    ) -> DailyPerfumeState {
        guard var storedState else {
            return DailyPerfumeState(
                profileCalculationCacheKey: profileCalculationCacheKey,
                dayKey: dayKey,
                currentPerfume: nil,
                currentReaction: nil,
                shownPerfumeIDs: [],
                savedPerfumes: [],
                dislikedPerfumeIDs: [],
                lastShownBrand: nil
            )
        }

        guard storedState.profileCalculationCacheKey == profileCalculationCacheKey else {
            storedState.profileCalculationCacheKey = profileCalculationCacheKey
            storedState.dayKey = dayKey
            storedState.currentPerfume = nil
            storedState.currentReaction = nil
            storedState.lastShownBrand = nil
            return storedState
        }

        guard storedState.dayKey != dayKey else {
            return storedState
        }

        storedState.dayKey = dayKey
        storedState.currentPerfume = nil
        storedState.currentReaction = nil
        return storedState
    }

    func makeProfileRequest(profileCalculation: ProfileCalculation) -> DailyPerfumeProfileRequest {
        DailyPerfumeProfileRequest(
            sun: profileCalculation.natalChart.sun.sign.rawValue,
            moon: profileCalculation.natalChart.moon.sign.rawValue,
            ascendant: profileCalculation.natalChart.ascendant.sign.rawValue,
            elementBalance: DailyPerfumeElementBalanceRequest(
                fire: profileCalculation.elementBalance.fire,
                earth: profileCalculation.elementBalance.earth,
                air: profileCalculation.elementBalance.air,
                water: profileCalculation.elementBalance.water
            )
        )
    }

    func requestCandidates(
        profileCalculation: ProfileCalculation,
        state: DailyPerfumeState
    ) async throws -> [DailyPerfumeCandidateResponse] {
        try await service.requestCandidates(
            profile: makeProfileRequest(profileCalculation: profileCalculation),
            excludedPerfumeIDs: excludedPerfumeIDs(from: state),
            lastShownBrand: state.lastShownBrand,
            limit: Self.candidateLimit
        )
    }

    func excludedPerfumeIDs(from state: DailyPerfumeState) -> [Int] {
        Set(
            state.shownPerfumeIDs
                + state.savedPerfumes.map(\.id)
                + state.dislikedPerfumeIDs
        )
            .sorted()
    }

    @MainActor
    func mutateCurrentPerfume(
        _ mutation: (inout DailyPerfumeState, DailyPerfumeSummary) -> Void,
        reaction: DailyPerfumeReaction
    ) {
        guard
            var state = stateStorage.loadState(),
            let currentPerfume = state.currentPerfume,
            state.currentReaction == .pending
        else {
            return
        }

        mutation(&state, currentPerfume)
        state.currentReaction = reaction
        stateStorage.saveState(state)

        viewModel.state = .content(currentPerfume, reaction)
    }

    func appendUnique(_ perfumeID: Int, to perfumeIDs: inout [Int]) {
        guard !perfumeIDs.contains(perfumeID) else {
            return
        }

        perfumeIDs.append(perfumeID)
    }

    @MainActor
    func setState(_ state: DailyPerfumeViewState) {
        viewModel.state = state
    }
}
