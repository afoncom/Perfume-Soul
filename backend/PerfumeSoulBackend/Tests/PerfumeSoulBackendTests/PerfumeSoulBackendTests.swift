import Foundation
@testable import PerfumeSoulBackend
import Testing
import VaporTesting

@Suite("App Tests")
struct PerfumeSoulBackendTests {
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }

    @Test("Test Daily Horoscopes Route")
    func dailyHoroscopes() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "horoscope/daily/2026-04-11", afterResponse: { res async throws in
                #expect(res.status == .ok)

                let horoscopes = try JSONDecoder().decode([DailyHoroscope].self, from: Data(res.body.string.utf8))
                #expect(horoscopes.count == 2)
                #expect(horoscopes.allSatisfy { $0.date == "2026-04-11" })
                #expect(horoscopes.map(\.sign) == ["aries", "leo"])
            })
        }
    }

    @Test("Test Daily Horoscope Loader For Date")
    func dailyHoroscopeLoaderForDate() throws {
        let horoscopes = try DailyHoroscopeLoader.load(date: "2026-04-11")

        #expect(horoscopes.count == 2)
        #expect(horoscopes.allSatisfy { $0.date == "2026-04-11" })
    }
}
