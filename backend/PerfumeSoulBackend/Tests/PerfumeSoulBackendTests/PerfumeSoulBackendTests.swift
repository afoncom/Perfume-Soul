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

    @Test("Test Historical Perfumery Route")
    func historicalPerfumery() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "perfumery-history/04-11", afterResponse: { res async throws in
                #expect(res.status == .ok)

                let historyDay = try res.content.decode(PerfumeryHistoryDay.self)
                #expect(historyDay.dateKey == "04-11")
                #expect(historyDay.title == "Этот день в парфюмерии")
                #expect(historyDay.items.count == 1)
                #expect(historyDay.items[0].year == 1921)
            })
        }
    }
}
