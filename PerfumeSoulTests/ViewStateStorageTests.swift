import XCTest
@testable import PerfumeSoul

final class ViewStateStorageTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()

        suiteName = "ViewStateStorageTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil

        super.tearDown()
    }

    func testStorageRoundTripsDailyPerfumeState() {
        let storage = makeStorage()
        let expected = makeState()

        storage.saveState(expected)

        XCTAssertEqual(storage.loadState(), expected)
    }

    func testStorageRestoresStateAfterStorageRecreation() {
        let expected = makeState()
        makeStorage().saveState(expected)

        let restoredState = makeStorage().loadState()

        XCTAssertEqual(restoredState, expected)
    }

    func testClearStateRemovesPersistedDailyPerfumeState() {
        let storage = makeStorage()
        storage.saveState(makeState())

        storage.clearState()

        XCTAssertNil(storage.loadState())
    }

    func testDayKeyUsesGregorianLocalCalendar() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try! XCTUnwrap(TimeZone(identifier: "Europe/Madrid"))
        let date = try! XCTUnwrap(
            calendar.date(
                from: DateComponents(year: 2026, month: 9, day: 5, hour: 12)
            )
        )
        let provider = DailyPerfumeDayKeyProviderImpl(calendar: calendar) { date }

        XCTAssertEqual(provider.todayKey(), "2026-09-05")
    }
}

extension ViewStateStorageTests {
    private func makeStorage() -> ViewStateStorage<DailyPerfumeState> {
        ViewStateStorage(
            userDefaults: userDefaults,
            storableKey: "dailyPerfume.state"
        )
    }

    private func makeState() -> DailyPerfumeState {
        DailyPerfumeState(
            profileCalculationCacheKey: "profileCalculation:v1|1990-01-01",
            dayKey: "2026-09-05",
            currentPerfume: DailyPerfumeSummary(
                id: 42,
                perfumeName: "Oud Wood",
                brandName: "Tom Ford"
            ),
            currentReaction: .pending,
            shownPerfumeIDs: [42],
            savedPerfumes: [
                DailyPerfumeSummary(
                    id: 17,
                    perfumeName: "Santal 33",
                    brandName: "Le Labo"
                )
            ],
            dislikedPerfumeIDs: [8],
            lastShownBrand: "Tom Ford"
        )
    }
}
