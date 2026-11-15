import Foundation
import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct DailyHoroscopeRouteTests {
    @Test("The endpoint returns the requested day in Russian or English")
    func localizedDailyHoroscopes() async throws {
        let days = try DailyHoroscopeSeed.days()
        let day = try #require(days.first)
        let models = day.signs.enumerated().map { index, pair in
            DailyHoroscopeEntryModel(
                dateKey: day.date,
                sign: pair.key,
                energyOfDayRu: pair.value.ru,
                energyOfDayEn: pair.value.en,
                sortOrder: index + 1
            )
        }
        let database = ArrayTestDatabase()
        database.append(models)
        database.append(models)
        let instant = try #require(ISO8601DateFormatter().date(from: "2026-12-01T12:00:00Z"))

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app, horoscopeClock: DailyHoroscopeClock { instant })

            for (language, expected) in [("ru", day.signs["aries"]?.ru), ("en", day.signs["aries"]?.en)] {
                try await app.testing().test(
                    .GET,
                    "/horoscope/daily?timeZone=UTC",
                    headers: ["Accept-Language": language]
                ) { response in
                    #expect(response.status == .ok)
                    let horoscopes = try JSONDecoder().decode(
                        [DailyHoroscope].self,
                        from: Data(response.body.string.utf8)
                    )
                    #expect(horoscopes.count == 12)
                    #expect(horoscopes.first { $0.sign == "aries" }?.energyOfDay == expected)
                }
            }
        }
    }

    @Test("The endpoint returns 404 before the catalog starts")
    func missingDate() async throws {
        let database = ArrayTestDatabase()
        database.append([])
        let instant = try #require(ISO8601DateFormatter().date(from: "2026-11-30T12:00:00Z"))

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app, horoscopeClock: DailyHoroscopeClock { instant })
            try await app.testing().test(.GET, "/horoscope/daily?timeZone=UTC") { response in
                #expect(response.status == .notFound)
            }
        }
    }

    @Test("The endpoint rejects an invalid time zone")
    func invalidTimeZone() async throws {
        try await withApp { app in
            try routes(app)
            try await app.testing().test(.GET, "/horoscope/daily?timeZone=Invalid") { response in
                #expect(response.status == .badRequest)
            }
        }
    }
}
