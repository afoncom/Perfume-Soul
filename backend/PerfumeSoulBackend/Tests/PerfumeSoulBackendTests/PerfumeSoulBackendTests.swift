import Foundation
@testable import PerfumeSoulBackend
import Testing
import VaporTesting

@Suite("App Tests")
struct PerfumeSoulBackendTests {
    @Test("Test Historical Perfumery Route")
    func historicalPerfumery() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "perfumery-history/2026-04-18", afterResponse: { res async throws in
                try #require(res.status == .ok)

                let items = try JSONDecoder().decode([PerfumeryHistoryItem].self, from: Data(res.body.string.utf8))
                #expect(items.count == 1)
                #expect(items[0].year == 1921)
            })
        }
    }

    @Test("Test Daily Horoscopes Route")
    func dailyHoroscopes() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "horoscope/daily/2026-04-18", afterResponse: { res async throws in
                #expect(res.status == .ok)

                let horoscopes = try JSONDecoder().decode([DailyHoroscope].self, from: Data(res.body.string.utf8))
                #expect(horoscopes.count == 12)
                #expect(horoscopes.map(\.sign).contains("leo"))
            })
        }
    }

    @Test("Test Daily Horoscope Loader For Date")
    func dailyHoroscopeLoaderForDate() throws {
        let horoscopes = try DailyHoroscopeLoader.load(date: "2026-04-18")

        #expect(horoscopes.count == 12)
        #expect(horoscopes.map(\.sign).contains("leo"))
    }
}
