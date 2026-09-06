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

        await presenter.resolve()

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

        await presenter.resolve()

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

        await presenter.resolve()
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

        await presenter.resolve()
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

        await presenter.resolve()

        XCTAssertEqual(service.requests.first?.excludedPerfumeIDs, [5, 8, 9, 11, 17, 42])
    }

    @MainActor
    func testResolveIgnoresSecondCallWhileCandidateRequestIsInProgress() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        previousState.shownPerfumeIDs = []
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            candidates: [makeCandidate(id: 7, score: 0.8)],
            suspendsRequests: true
        )
        let firstRequestExpectation = expectation(description: "first candidate request")
        let unexpectedSecondRequestExpectation = expectation(
            description: "second candidate request"
        )
        unexpectedSecondRequestExpectation.isInverted = true
        service.onRequest = { requestCount in
            if requestCount == 1 {
                firstRequestExpectation.fulfill()
            } else {
                unexpectedSecondRequestExpectation.fulfill()
            }
        }
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        let firstResolveTask = Task {
            await presenter.resolve()
        }
        await fulfillment(of: [firstRequestExpectation], timeout: 1)

        let secondResolveTask = Task {
            await presenter.resolve()
        }
        await fulfillment(of: [unexpectedSecondRequestExpectation], timeout: 0.1)

        XCTAssertEqual(service.requests.count, 1)

        service.resumeRequests()
        await firstResolveTask.value
        await secondResolveTask.value
    }

    @MainActor
    func testResolveRetriesWithSavedAndDislikedExclusionsAfterEmptyCandidates() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            responses: [
                .success([]),
                .success([makeCandidate(id: 7, score: 0.8)])
            ]
        )
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve()

        XCTAssertEqual(service.requests.count, 2)
        XCTAssertEqual(service.requests[0].excludedPerfumeIDs, [8, 17, 42])
        XCTAssertEqual(service.requests[1].excludedPerfumeIDs, [8, 17])
        XCTAssertEqual(viewModel.state, .content(makeSummary(id: 7), .pending))
    }

    @MainActor
    func testResolveShowsExhaustedWhenCandidatesRemainEmptyAfterFallback() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            responses: [.success([]), .success([])]
        )
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve()

        XCTAssertEqual(service.requests.count, 2)
        XCTAssertEqual(viewModel.state, .exhausted)
    }

    @MainActor
    func testResolveShowsFailedWhenFallbackRequestFails() async {
        var previousState = makeState()
        previousState.dayKey = "2026-09-04"
        previousState.currentPerfume = nil
        previousState.currentReaction = nil
        let storage = DailyPerfumeStateStorageMock(state: previousState)
        let service = DailyPerfumeServiceMock(
            responses: [.success([]), .failure(DailyPerfumeServiceMockError.requestFailed)]
        )
        let viewModel = DailyPerfumeViewModel()
        let presenter = makePresenter(
            viewModel: viewModel,
            service: service,
            storage: storage
        )

        await presenter.resolve()

        XCTAssertEqual(service.requests.count, 2)
        XCTAssertEqual(viewModel.state, .failed)
    }

    @MainActor
    func testWeightedSelectionUsesInjectedRandomValue() async {
        let firstCandidateSelectionService = DailyPerfumeSelectionServiceImpl(
            randomSource: DailyPerfumeRandomSourceMock(value: 0.5)
        )
        let secondCandidateSelectionService = DailyPerfumeSelectionServiceImpl(
            randomSource: DailyPerfumeRandomSourceMock(value: 0.9)
        )
        let candidates = [
            makeCandidate(id: 1, score: 0.9),
            makeCandidate(id: 2, score: 0.8)
        ]

        let firstCandidate = firstCandidateSelectionService.selectCandidate(from: candidates)
        let secondCandidate = secondCandidateSelectionService.selectCandidate(from: candidates)

        XCTAssertEqual(firstCandidate?.id, 1)
        XCTAssertEqual(secondCandidate?.id, 2)
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
            profileService: DailyPerfumeProfileServiceMock(profile: makeProfile()),
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

private final class DailyPerfumeProfileServiceMock: ProfileService {
    private let profile: Profile?

    init(profile: Profile?) {
        self.profile = profile
    }

    func saveProfile(_ profile: Profile) { }

    func replaceProfile(_ profile: Profile) async { }

    func fetchProfile() async -> Profile? {
        profile
    }

    func deleteProfile(_ profile: Profile) async { }
}

private enum DailyPerfumeServiceMockError: Error {
    case requestFailed
}

private final class DailyPerfumeServiceMock: DailyPerfumeService {
    struct Request: Equatable {
        let profile: DailyPerfumeProfileRequest
        let excludedPerfumeIDs: [Int]
        let lastShownBrand: String?
        let limit: Int
    }

    var requests: [Request] = []
    var onRequest: ((Int) -> Void)?
    let candidates: [DailyPerfumeCandidateResponse]
    private var responses: [Result<[DailyPerfumeCandidateResponse], Error>]
    private let suspendsRequests: Bool
    private var continuations: [CheckedContinuation<[DailyPerfumeCandidateResponse], Never>] = []

    init(
        candidates: [DailyPerfumeCandidateResponse],
        suspendsRequests: Bool = false
    ) {
        self.candidates = candidates
        responses = [.success(candidates)]
        self.suspendsRequests = suspendsRequests
    }

    init(responses: [Result<[DailyPerfumeCandidateResponse], Error>]) {
        candidates = []
        self.responses = responses
        suspendsRequests = false
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
        onRequest?(requests.count)

        if suspendsRequests {
            return await withCheckedContinuation { continuation in
                continuations.append(continuation)
            }
        }

        let response = responses.isEmpty ? .success(candidates) : responses.removeFirst()
        switch response {
        case let .success(candidates):
            return candidates
        case let .failure(error):
            throw error
        }
    }

    func resumeRequests() {
        continuations.forEach { continuation in
            continuation.resume(returning: candidates)
        }
        continuations = []
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
