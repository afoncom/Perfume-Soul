import XCTest
@testable import PerfumeSoul

final class DailyHoroscopeRefreshOrderTests: XCTestCase {
    @MainActor
    func testTodayFinishesLoadingWhenHistoryAndHoroscopeBothFail() async {
        let viewModel = TodayViewModel()
        let presenter = TodayPresenterImpl(
            viewModel: viewModel,
            router: TodayRouterStub(),
            perfumeHistoryService: FailingHistoryServiceStub(),
            dailyHoroscopeService: FailingHoroscopeServiceStub(),
            profileService: ProfileServiceStub()
        )

        await presenter.onAppear()

        XCTAssertFalse(viewModel.isLoadingHoroscope)
        XCTAssertNil(viewModel.personalHoroscope)
        XCTAssertTrue(viewModel.hasPreferredZodiacSign)
        XCTAssertEqual(viewModel.horoscopePlaceholder, String(localized: "today.energy.unavailable"))
        guard case .unavailable = viewModel.viewState else {
            return XCTFail("History must finish loading after a failure")
        }
    }

    @MainActor
    func testTodayKeepsLatestHoroscopeWhenEarlierRequestFinishesLast() async {
        let service = PendingHoroscopeService()
        let viewModel = TodayViewModel()
        let presenter = TodayPresenterImpl(
            viewModel: viewModel,
            router: TodayRouterStub(),
            perfumeHistoryService: HistoryServiceStub(),
            dailyHoroscopeService: service,
            profileService: ProfileServiceStub()
        )

        let firstStarted = expectation(description: "first horoscope request started")
        service.onRequest = { count in
            if count == 1 { firstStarted.fulfill() }
        }
        let first = Task { await presenter.onAppear() }
        await fulfillment(of: [firstStarted], timeout: 2)

        let secondStarted = expectation(description: "second horoscope request started")
        service.onRequest = { count in
            if count == 2 { secondStarted.fulfill() }
        }
        let second = Task { await presenter.onAppear() }
        await fulfillment(of: [secondStarted], timeout: 2)

        service.complete(1, with: [DailyHoroscope(sign: "aries", energyOfDay: "December 2")])
        await second.value
        service.complete(0, with: [DailyHoroscope(sign: "aries", energyOfDay: "December 1")])
        await first.value

        XCTAssertEqual(viewModel.dailyHoroscopes.first?.energyOfDay, "December 2")
        XCTAssertEqual(viewModel.personalHoroscope?.energyOfDay, "December 2")
    }

    @MainActor
    func testTodayEnergyKeepsLatestHoroscopeWhenEarlierRequestFinishesLast() async {
        let service = PendingHoroscopeService()
        let viewModel = TodayEnergyViewModel(
            personalDailyHoroscope: DailyHoroscope(sign: "aries", energyOfDay: "Initial"),
            dailyHoroscopes: []
        )
        let presenter = TodayEnergyPresenterImpl(
            viewModel: viewModel,
            router: TodayEnergyRouterImpl(navigationController: nil),
            dailyHoroscopeService: service
        )

        let firstStarted = expectation(description: "first detail request started")
        service.onRequest = { count in
            if count == 1 { firstStarted.fulfill() }
        }
        let first = Task { await presenter.refresh() }
        await fulfillment(of: [firstStarted], timeout: 2)

        let secondStarted = expectation(description: "second detail request started")
        service.onRequest = { count in
            if count == 2 { secondStarted.fulfill() }
        }
        let second = Task { await presenter.refresh() }
        await fulfillment(of: [secondStarted], timeout: 2)

        service.complete(1, with: [DailyHoroscope(sign: "aries", energyOfDay: "December 2")])
        await second.value
        service.complete(0, with: [DailyHoroscope(sign: "aries", energyOfDay: "December 1")])
        await first.value

        XCTAssertEqual(viewModel.personalDailyHoroscope.energyOfDay, "December 2")
        XCTAssertEqual(viewModel.dailyHoroscopes.first?.energyOfDay, "December 2")
    }
}

private final class FailingHistoryServiceStub: PerfumeHistoryService {
    func requestPerfumeHistory() async throws -> PerfumeHistory {
        throw URLError(.notConnectedToInternet)
    }
}

private final class FailingHoroscopeServiceStub: DailyHoroscopeService {
    func requestDailyHoroscope() async throws -> [DailyHoroscope] {
        throw URLError(.notConnectedToInternet)
    }
}

@MainActor
private final class PendingHoroscopeService: DailyHoroscopeService {
    var onRequest: ((Int) -> Void)?
    private var pending: [CheckedContinuation<[DailyHoroscope], Error>] = []

    func requestDailyHoroscope() async throws -> [DailyHoroscope] {
        try await withCheckedThrowingContinuation { continuation in
            pending.append(continuation)
            onRequest?(pending.count)
        }
    }

    func complete(_ index: Int, with horoscopes: [DailyHoroscope]) {
        pending[index].resume(returning: horoscopes)
    }
}

private final class HistoryServiceStub: PerfumeHistoryService {
    func requestPerfumeHistory() async throws -> PerfumeHistory {
        PerfumeHistory(
            publicationDate: "2026-12-01",
            year: 2026,
            title: "History",
            fullStory: "Full"
        )
    }
}

private final class ProfileServiceStub: ProfileService {
    func saveProfile(_ profile: Profile) { }
    func replaceProfile(_ profile: Profile) async { }
    func fetchProfile() async -> Profile? {
        Profile(
            name: "Test",
            birthDate: "01.04.1990",
            birthTime: "12:00",
            birthPlace: "Madrid",
            birthLatitude: nil,
            birthLongitude: nil,
            birthTimeZoneIdentifier: nil,
            calculatedSunSign: "aries"
        )
    }
    func deleteProfile(_ profile: Profile) async { }
}

private final class TodayRouterStub: TodayRouter {
    func showTodayEnergyScreen(
        personalDailyHoroscope: DailyHoroscope,
        dailyHoroscopes: [DailyHoroscope]
    ) { }

    func showDayInPerfumeryScreen(historyFact: PerfumeHistory) { }
}
