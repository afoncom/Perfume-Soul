import Foundation
import Testing
import VaporTesting

//@Suite("App Tests")
//struct PerfumeSoulBackendTests {
//    @Test("Test Historical Perfumery Route")
//    func historicalPerfumery() async throws {
//        try await withApp(configure: configure) { app in
//            try await app.testing().test(.GET, "perfumery-history/2026-04-18", afterResponse: { res async throws in
//                try #require(res.status == .ok)
//
//                let items = try JSONDecoder().decode([PerfumeryHistoryItem].self, from: Data(res.body.string.utf8))
//                #expect(items.count == 1)
//                #expect(items[0].year == 1921)
//            })
//        }
//    }
//}
