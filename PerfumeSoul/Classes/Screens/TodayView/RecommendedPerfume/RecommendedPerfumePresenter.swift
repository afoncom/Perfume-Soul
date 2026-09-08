import Foundation

protocol RecommendedPerfumePresenter {
    func resolve() async
    func retry() async
    @MainActor func perfumeTapped(_ perfume: DailyPerfumeSummary)
    @MainActor func savePerfume(_ perfume: DailyPerfumeSummary)
}

final class RecommendedPerfumePresenterImpl {
    private static let visibleCount = 10
    private static let candidateLimit = 20
    private let viewModel: RecommendedPerfumeViewModel
    private let service: RecommendedPerfumeService
    private let profileService: ProfileService
    private let collectionService: PerfumeCollectionService
    private let topStorage: PersonalPerfumeTopStorage
    private let stateStorage: RecommendedPerfumeStateStorage
    private let router: RecommendedPerfumeRouter

    init(
        viewModel: RecommendedPerfumeViewModel,
        service: RecommendedPerfumeService,
        profileService: ProfileService,
        collectionService: PerfumeCollectionService,
        topStorage: PersonalPerfumeTopStorage,
        stateStorage: RecommendedPerfumeStateStorage,
        router: RecommendedPerfumeRouter
    ) {
        self.viewModel = viewModel
        self.service = service
        self.profileService = profileService
        self.collectionService = collectionService
        self.topStorage = topStorage
        self.stateStorage = stateStorage
        self.router = router
    }
}

extension RecommendedPerfumePresenterImpl: RecommendedPerfumePresenter {
    func resolve() async {
        guard await beginResolving() else {
            return
        }
        defer {
            finishResolving()
        }

        guard let profile = await profileService.fetchProfile(), let calculation = profile.cachedProfileCalculation else {
            await setState(.missingProfile)
            return
        }
        let topIDs = topStorage.loadPerfumeIDs()
        let collection = collectionService.loadState()
        let exclusions = Set(topIDs + collection.savedPerfumes.map(\.id) + collection.dislikedPerfumeIDs)
        let excludedPerfumeIDs = exclusions.sorted()
        let weekKey = Self.currentWeekKey()

        let storedState = stateStorage.loadState()
        var fallbackPerfumes: [DailyPerfumeSummary] = []

        if let state = storedState,
            state.profileCalculationCacheKey == profile.profileCalculationCacheKey,
            state.topPerfumeIDs == topIDs,
            state.weekKey == weekKey {
            let valid = state.perfumes.filter { !exclusions.contains($0.id) }
            let validReserve = state.reservePerfumes.filter { perfume in
                !exclusions.contains(perfume.id) && !valid.contains { $0.id == perfume.id }
            }
            let replacementCount = max(0, Self.visibleCount - valid.count)
            let replacements = Array(validReserve.prefix(replacementCount))
            let perfumes = valid + replacements
            let reserve = Array(validReserve.dropFirst(replacements.count))

            if perfumes != state.perfumes || reserve != state.reservePerfumes {
                stateStorage.saveState(
                    RecommendedPerfumeState(
                        perfumes: perfumes,
                        reservePerfumes: reserve,
                        topPerfumeIDs: topIDs,
                        profileCalculationCacheKey: profile.profileCalculationCacheKey,
                        weekKey: weekKey,
                        resolvedExcludedPerfumeIDs: state.resolvedExcludedPerfumeIDs
                    )
                )
            }

            if perfumes.count == Self.visibleCount {
                await show(perfumes)
                return
            }

            fallbackPerfumes = perfumes

            if state.resolvedExcludedPerfumeIDs == excludedPerfumeIDs {
                await show(fallbackPerfumes)
                return
            }
        } else if let state = storedState,
            state.profileCalculationCacheKey == profile.profileCalculationCacheKey,
            state.topPerfumeIDs == topIDs {
            fallbackPerfumes = Array(
                state.perfumes
                    .filter { !exclusions.contains($0.id) }
                    .prefix(8)
            )
        }

        let stateBeforeRequest = stateStorage.loadState()

        do {
            let responses = try await service.requestCandidates(
                profile: makeProfileRequest(calculation),
                excludedPerfumeIDs: excludedPerfumeIDs,
                limit: Self.candidateLimit
            )
            let candidates = responses.map {
                DailyPerfumeSummary(
                    id: $0.id,
                    perfumeName: $0.perfumeName,
                    brandName: $0.brandName
                )
            }
            let additions = candidates.filter { candidate in
                !exclusions.contains(candidate.id) && !fallbackPerfumes.contains { $0.id == candidate.id }
            }

            guard isRequestStateCurrent(
                stateBeforeRequest: stateBeforeRequest,
                collection: collection,
                topPerfumeIDs: topIDs
            ) else {
                await scheduleRefreshAfterResolving()
                return
            }

            let perfumes = Array((fallbackPerfumes + additions).prefix(Self.visibleCount))
            let reserve = Array(additions.dropFirst(max(0, Self.visibleCount - fallbackPerfumes.count)))
            stateStorage.saveState(
                RecommendedPerfumeState(
                    perfumes: perfumes,
                    reservePerfumes: reserve,
                    topPerfumeIDs: topIDs,
                    profileCalculationCacheKey: profile.profileCalculationCacheKey,
                    weekKey: weekKey,
                    resolvedExcludedPerfumeIDs: excludedPerfumeIDs
                )
            )
            await show(perfumes)
        } catch {
            guard isRequestStateCurrent(
                stateBeforeRequest: stateBeforeRequest,
                collection: collection,
                topPerfumeIDs: topIDs
            ) else {
                await scheduleRefreshAfterResolving()
                return
            }

            if fallbackPerfumes.isEmpty {
                await setState(.failed)
            } else {
                await show(fallbackPerfumes)
            }
        }
    }

    func retry() async {
        await resolve()
    }

    @MainActor func perfumeTapped(_ perfume: DailyPerfumeSummary) {
        router.showPerfumeDetailsScreen(perfume: SearchPerfumeItem(id: perfume.id, name: perfume.perfumeName))
    }

    @MainActor func savePerfume(_ perfume: DailyPerfumeSummary) {
        collectionService.save(
            PerfumeCollectionPerfume(
                id: perfume.id,
                perfumeName: perfume.perfumeName,
                brandName: perfume.brandName,
                source: .manual
            )
        )
        guard var state = stateStorage.loadState() else {
            if case var .content(perfumes) = viewModel.state {
                perfumes.removeAll { $0.id == perfume.id }
                viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
            }
            scheduleRefreshAfterResolvingIfNeeded()
            return
        }
        state.perfumes.removeAll { $0.id == perfume.id }
        if let replacement = state.reservePerfumes.first {
            state.perfumes.append(replacement)
            state.reservePerfumes.removeFirst()
        }
        stateStorage.saveState(state)
        viewModel.state = state.perfumes.isEmpty ? .empty : .content(state.perfumes)
        scheduleRefreshAfterResolvingIfNeeded()
    }
}

extension RecommendedPerfumePresenterImpl {
    private func makeProfileRequest(_ calculation: ProfileCalculation) -> DailyPerfumeProfileRequest {
        DailyPerfumeProfileRequest(
            sun: calculation.natalChart.sun.sign.rawValue,
            moon: calculation.natalChart.moon.sign.rawValue,
            ascendant: calculation.natalChart.ascendant.sign.rawValue,
            elementBalance: DailyPerfumeElementBalanceRequest(
                fire: calculation.elementBalance.fire,
                earth: calculation.elementBalance.earth,
                air: calculation.elementBalance.air,
                water: calculation.elementBalance.water
            )
        )
    }

    private func show(_ perfumes: [DailyPerfumeSummary]) async {
        await setState(perfumes.isEmpty ? .empty : .content(perfumes))
    }

    private func setState(_ state: RecommendedPerfumeViewState) async {
        await MainActor.run { viewModel.state = state }
    }

    private func beginResolving() async -> Bool {
        await MainActor.run {
            guard !viewModel.isResolving else {
                return false
            }

            viewModel.isResolving = true

            if case .content = viewModel.state {
                return true
            }

            viewModel.state = .loading
            return true
        }
    }

    private func finishResolving() {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            viewModel.isResolving = false

            guard viewModel.shouldRefreshAfterResolving else {
                return
            }

            viewModel.shouldRefreshAfterResolving = false
            await resolve()
        }
    }

    private func isRequestStateCurrent(
        stateBeforeRequest: RecommendedPerfumeState?,
        collection: PerfumeCollectionState,
        topPerfumeIDs: [Int]
    ) -> Bool {
        stateStorage.loadState() == stateBeforeRequest &&
            collectionService.loadState() == collection &&
            topStorage.loadPerfumeIDs() == topPerfumeIDs
    }

    private func scheduleRefreshAfterResolving() async {
        await MainActor.run {
            viewModel.shouldRefreshAfterResolving = true
        }
    }

    @MainActor
    private func scheduleRefreshAfterResolvingIfNeeded() {
        guard viewModel.isResolving else {
            return
        }

        viewModel.shouldRefreshAfterResolving = true
    }

    private static func currentWeekKey() -> String {
        let calendar = Calendar(identifier: .iso8601)
        let parts = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return "\(parts.yearForWeekOfYear ?? 0)-\(parts.weekOfYear ?? 0)"
    }
}
