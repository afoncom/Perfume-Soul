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

    @Test("Test Daily Horoscope Route")
    func dailyHoroscope() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "horoscope/daily/aries/2026-04-11", afterResponse: { res async throws in
                #expect(res.status == .ok)

                let horoscope = try res.content.decode(DailyHoroscope.self)
                #expect(horoscope.sign == "aries")
                #expect(horoscope.date == "2026-04-11")
                #expect(horoscope.energyOfDay.text == "Сегодня хороший день для инициативы и быстрых решений.")
            })
        }
    }
}
