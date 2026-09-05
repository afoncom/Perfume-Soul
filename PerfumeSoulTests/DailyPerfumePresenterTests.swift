import XCTest
@testable import PerfumeSoul

final class DailyPerfumePresenterTests: XCTestCase {
    @MainActor
    func testResolveRestoresCurrentDayPerfumeWithoutRequest() async {
        let storage = DailyPerfumeStateStorageMock(state: makeState())
        let service = DailyPerfumeServiceMock(candidates: [])
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve(profile: makeProfile())

        XCTAssertEqual(service.requests.count, 0)
        XCTAssertEqual(viewModel.state, .content(makeSummary(id: 42), .pending))
    }

    @MainActor
    func testResolveOnNewDayPersistsSelectedPerfumeAsShown() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        previousState.shownPerfumeIDs = []
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            candidates: [makeCandidate(id: 7, score: 0.8)]
        )
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve(profile: makeProfile())

        XCTAssertEqual(viewModel.state, .content(makeSummary(id: 7), .pending))
        XCTAssertEqual(storage.state?.shownPerfumeIDs, [7])
        XCTAssertEqual(storage.state?.lastShownBrand, "Brand 7")
        XCTAssertEqual(service.requests.first?.excludedPerfumeIDs, [8, 17])
    }

    @MainActor
    func testSaveCurrentPerfumeAddsOneCabinetSummaryWithoutRequestingReplacement() async {
        let storage = DailyPerfumeStateStorageMock(state: makeState())
        let service = DailyPerfumeServiceMock(candidates: [])
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve(profile: makeProfile())
        presenter.saveCurrentPerfume()
        presenter.saveCurrentPerfume()

        XCTAssertEqual(viewModel.state, .content(makeSummary(id: 42), .saved))
        XCTAssertEqual(storage.state?.savedPerfumes, [makeSummary(id: 17), makeSummary(id: 42)])
        XCTAssertEqual(service.requests.count, 0)
    }

    @MainActor
    func testDismissCurrentPerfumeAddsPermanentExclusionWithoutReplacement() async {
        let storage = DailyPerfumeStateStorageMock(state: makeState())
        let service = DailyPerfumeServiceMock(candidates: [])
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve(profile: makeProfile())
        presenter.dismissCurrentPerfume()

        XCTAssertEqual(viewModel.state, .content(makeSummary(id: 42), .dismissed))
        XCTAssertEqual(storage.state?.dislikedPerfumeIDs, [8, 42])
        XCTAssertEqual(service.requests.count, 0)
    }

    @MainActor
    func testResolveUsesAllStoredExclusionsForNewCandidateRequest() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        previousState.shownPerfumeIDs = [42, 5]
        previousState.savedPerfumes = [makeSummary(id: 17), makeSummary(id: 9)]
        previousState.dislikedPerfumeIDs = [8, 11]
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            candidates: [makeCandidate(id: 7, score: 0.8)]
        )
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve(profile: makeProfile())

        XCTAssertEqual(service.requests.first?.excludedPerfumeIDs, [5, 8, 9, 11, 17, 42])
    }

    @MainActor
    func testWeightedSelectionUsesInjectedRandomValue() async {
        let selectionService = DailyPerfumeSelectionServiceImpl(
            randomSource: DailyPerfumeRandomSourceMock(value: 0)
        )
        let selectedCandidate = selectionService.selectCandidate(
            from: [
                makeCandidate(id: 1, score: 0.9),
                makeCandidate(id: 2, score: 0.8)
            ]
        )

        XCTAssertEqual(selectedCandidate?.id, 1)
    }
}

private extension DailyPerfumePresenterTests {
    func makePresenter(
        viewModel: DailyPerfumeViewModel,
        service: DailyPerfumeServiceMock,
        storage: DailyPerfumeStateStorageMock,
        randomValue: Double = 0.5
    ) -> DailyPerfumePresenterImpl {
        DailyPerfumePresenterImpl(
            viewModel: viewModel,
            router: DailyPerfumeRouterMock(),
            service: service,
            stateStorage: storage,
            dayKeyProvider: DailyPerfumeDayKeyProviderMock(),
            selectionService: DailyPerfumeSelectionServiceImpl(
                randomSource: DailyPerfumeRandomSourceMock(value: randomValue)
            )
        )
    }

    func makeProfile() -> Profile {
        Profile(
            name: "Alex",
            birthDate: "01.01.1990",
            birthTime: "12:00",
            birthPlace: "Madrid",
            birthLatitude: 40.4168,
            birthLongitude: -3.7038,
            birthTimeZoneIdentifier: "Europe/Madrid"
        )
        .withProfileCalculation(
            ProfileCalculation(
                natalChart: NatalChart(
                    sun: ZodiacPlacement(sign: .aquarius, longitude: 0),
                    moon: ZodiacPlacement(sign: .aquarius, longitude: 0),
                    ascendant: ZodiacPlacement(sign: .aquarius, longitude: 0)
                ),
                elementBalance: ElementBalance(fire: 0, earth: 0, air: 100, water: 0)
            )
        )
    }

    func makeState() -> DailyPerfumeState {
        DailyPerfumeState(
            profileCalculationCacheKey: makeProfile().profileCalculationCacheKey,
            dayKey: "2026-09-05",
            currentPerfume: makeSummary(id: 42),
            currentReaction: .pending,
            shownPerfumeIDs: [42],
            savedPerfumes: [makeSummary(id: 17)],
            dislikedPerfumeIDs: [8],
            lastShownBrand: "Brand 42"
        )
    }

    func makeSummary(id: Int) -> DailyPerfumeSummary {
        DailyPerfumeSummary(
            id: id,
            perfumeName: "Perfume \(id)",
            brandName: "Brand \(id)"
        )
    }

    func makeCandidate(id: Int, score: Double) -> DailyPerfumeCandidateResponse {
        DailyPerfumeCandidateResponse(
            id: id,
            perfumeName: "Perfume \(id)",
            brandName: "Brand \(id)",
            natalScore: score
        )
    }
}

private final class DailyPerfumeRouterMock: DailyPerfumeRouter {
    @MainActor
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) { }
}

private final class DailyPerfumeServiceMock: DailyPerfumeService {
    struct Request: Equatable {
        let profile: DailyPerfumeProfileRequest
        let excludedPerfumeIDs: [Int]
        let lastShownBrand: String?
        let limit: Int
    }

    var requests: [Request] = []
    let candidates: [DailyPerfumeCandidateResponse]

    init(candidates: [DailyPerfumeCandidateResponse]) {
        self.candidates = candidates
    }

    func requestCandidates(
        profile: DailyPerfumeProfileRequest,
        excludedPerfumeIDs: [Int],
        lastShownBrand: String?,
        limit: Int
    ) async throws -> [DailyPerfumeCandidateResponse] {
        requests.append(
            Request(
                profile: profile,
                excludedPerfumeIDs: excludedPerfumeIDs,
                lastShownBrand: lastShownBrand,
                limit: limit
            )
        )

        return candidates
    }
}

private final class DailyPerfumeStateStorageMock: DailyPerfumeStateStorage {
    var state: DailyPerfumeState?

    init(state: DailyPerfumeState? = nil) {
        self.state = state
    }

    func loadState() -> DailyPerfumeState? {
        state
    }

    func saveState(_ state: DailyPerfumeState) {
        self.state = state
    }

    func clearState() { }
}

private final class DailyPerfumeDayKeyProviderMock: DailyPerfumeDayKeyProvider {
    func todayKey() -> String { "2026-09-05" }
}

private final class DailyPerfumeRandomSourceMock: DailyPerfumeRandomSource {
    let value: Double

    init(value: Double) {
        self.value = value
    }

    func nextUnitInterval() -> Double { value }
}
