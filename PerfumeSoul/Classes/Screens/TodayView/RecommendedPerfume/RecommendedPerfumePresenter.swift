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

    init(viewModel: RecommendedPerfumeViewModel, service: RecommendedPerfumeService, profileService: ProfileService, collectionService: PerfumeCollectionService, topStorage: PersonalPerfumeTopStorage, stateStorage: RecommendedPerfumeStateStorage, router: RecommendedPerfumeRouter) {
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
        await MainActor.run { viewModel.state = .loading }
        guard let profile = await profileService.fetchProfile(), let calculation = profile.cachedProfileCalculation else {
            await show([])
            return
        }
        let topIDs = topStorage.loadPerfumeIDs()
        let collection = collectionService.loadState()
        let exclusions = Set(topIDs + collection.savedPerfumes.map(\.id) + collection.dislikedPerfumeIDs)
        let weekKey = Self.currentWeekKey()

        let storedState = stateStorage.loadState()
        if let state = storedState, state.profileCalculationCacheKey == profile.profileCalculationCacheKey, state.topPerfumeIDs == topIDs, state.weekKey == weekKey {
            let valid = state.perfumes.filter { !exclusions.contains($0.id) }
            if valid.count == state.perfumes.count {
                await show(valid)
                return
            }
        }

        do {
            let responses = try await service.requestCandidates(
                profile: makeProfileRequest(calculation),
                excludedPerfumeIDs: exclusions.sorted(),
                limit: Self.candidateLimit
            )
            let candidates = responses.map {
                DailyPerfumeSummary(
                    id: $0.id,
                    perfumeName: $0.perfumeName,
                    brandName: $0.brandName
                )
            }
            let old: [DailyPerfumeSummary]
            if let state = storedState,
                state.profileCalculationCacheKey == profile.profileCalculationCacheKey,
                state.topPerfumeIDs == topIDs {
                old = state.perfumes.filter { !exclusions.contains($0.id) }
            } else {
                old = []
            }
            let retained = Array(old.prefix(8))
            let additions = candidates.filter { candidate in !retained.contains(where: { $0.id == candidate.id }) }
            let perfumes = Array((retained + additions).prefix(Self.visibleCount))
            let reserve = Array(additions.dropFirst(max(0, Self.visibleCount - retained.count)))
            stateStorage.saveState(
                RecommendedPerfumeState(
                    perfumes: perfumes,
                    reservePerfumes: reserve,
                    topPerfumeIDs: topIDs,
                    profileCalculationCacheKey: profile.profileCalculationCacheKey,
                    weekKey: weekKey
                )
            )
            await show(perfumes)
        } catch {
            await MainActor.run { viewModel.state = .failed }
        }
    }

    func retry() async {
        await resolve()
    }

    @MainActor func perfumeTapped(_ perfume: DailyPerfumeSummary) {
        router.showPerfumeDetailsScreen(perfume: SearchPerfumeItem(id: perfume.id, name: perfume.perfumeName))
    }

    @MainActor func savePerfume(_ perfume: DailyPerfumeSummary) {
        collectionService.save(PerfumeCollectionPerfume(id: perfume.id, perfumeName: perfume.perfumeName, brandName: perfume.brandName, source: .manual))
        guard var state = stateStorage.loadState() else {
            if case var .content(perfumes) = viewModel.state {
                perfumes.removeAll { $0.id == perfume.id }
                viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes)
            }
            return
        }
        state.perfumes.removeAll { $0.id == perfume.id }
        if let replacement = state.reservePerfumes.first {
            state.perfumes.append(replacement)
            state.reservePerfumes.removeFirst()
        }
        stateStorage.saveState(state)
        viewModel.state = state.perfumes.isEmpty ? .empty : .content(state.perfumes)
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
        await MainActor.run { viewModel.state = perfumes.isEmpty ? .empty : .content(perfumes) }
    }

    private static func currentWeekKey() -> String {
        let calendar = Calendar(identifier: .iso8601)
        let parts = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return "\(parts.yearForWeekOfYear ?? 0)-\(parts.weekOfYear ?? 0)"
    }
}
