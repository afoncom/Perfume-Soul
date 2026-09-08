import XCTest
@testable import PerfumeSoul

final class PerfumeCollectionStorageTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "PerfumeCollectionStorageTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testStorageMigratesSavedAndDislikedPerfumesFromDailyState() {
        DailyPerfumeStateStorageImpl(userDefaults: userDefaults).saveState(
            DailyPerfumeState(profileCalculationCacheKey: nil, dayKey: "2026-09-07", currentPerfume: nil, currentReaction: nil, shownPerfumeIDs: [], savedPerfumes: [DailyPerfumeSummary(id: 42, perfumeName: "Blanche", brandName: "Byredo")], dislikedPerfumeIDs: [8], lastShownBrand: nil)
        )

        let state = PerfumeCollectionStorageImpl(userDefaults: userDefaults).loadState()

        XCTAssertEqual(state.savedPerfumes, [PerfumeCollectionPerfume(id: 42, perfumeName: "Blanche", brandName: "Byredo", source: .dailyPerfume)])
        XCTAssertEqual(state.dislikedPerfumeIDs, [8])
    }

    func testStorageRoundTripsCollectionState() {
        let storage = PerfumeCollectionStorageImpl(userDefaults: userDefaults)
        let expected = PerfumeCollectionState(savedPerfumes: [PerfumeCollectionPerfume(id: 42, perfumeName: "Blanche", brandName: "Byredo", source: .manual)], dislikedPerfumeIDs: [8])

        storage.saveState(expected)

        XCTAssertEqual(storage.loadState(), expected)
    }
}
