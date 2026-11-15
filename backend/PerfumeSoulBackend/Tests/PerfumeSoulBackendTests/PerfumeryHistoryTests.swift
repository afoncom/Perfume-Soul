import Foundation
import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct PerfumeryHistoryTests {
    @Test("The published catalog covers every date with distinct December stories")
    func catalogCoverage() throws {
        let entries = try PerfumeryHistorySeed.entries()
        let byDate = Dictionary(uniqueKeysWithValues: entries.map { ($0.dateKey, $0) })
        let utc = try #require(TimeZone(identifier: "UTC"))
        let decemberFirst = try #require(ISO8601DateFormatter().date(from: "2026-12-01T12:00:00Z"))
        let decemberSecond = try #require(ISO8601DateFormatter().date(from: "2026-12-02T12:00:00Z"))
        let firstKey = PerfumeryHistoryCalendar.dateKey(now: decemberFirst, timeZone: utc)
        let secondKey = PerfumeryHistoryCalendar.dateKey(now: decemberSecond, timeZone: utc)

        #expect(entries.count == 731)
        #expect(byDate.count == 731)
        #expect(firstKey == "2026-12-01")
        #expect(secondKey == "2026-12-02")
        #expect(byDate[firstKey]?.titleRu != byDate[secondKey]?.titleRu)
        #expect(byDate[firstKey]?.fullStoryRu != byDate[secondKey]?.fullStoryRu)
        #expect(byDate["2028-02-29"] != nil)
        #expect(byDate["2028-11-30"] != nil)
        #expect(byDate["2028-12-01"] == nil)
    }

    @Test("The calendar selects local dates across midnight and New Year")
    func localDateKey() throws {
        let instant = try #require(ISO8601DateFormatter().date(from: "2027-01-01T00:30:00Z"))
        let madrid = try #require(TimeZone(identifier: "Europe/Madrid"))
        let losAngeles = try #require(TimeZone(identifier: "America/Los_Angeles"))

        #expect(PerfumeryHistoryCalendar.dateKey(now: instant, timeZone: madrid) == "2027-01-01")
        #expect(PerfumeryHistoryCalendar.dateKey(now: instant, timeZone: losAngeles) == "2026-12-31")
        let leapDay = try #require(ISO8601DateFormatter().date(from: "2028-02-29T12:00:00Z"))
        #expect(PerfumeryHistoryCalendar.dateKey(now: leapDay, timeZone: madrid) == "2028-02-29")
    }

    @Test("An absent publication date returns no story")
    func missingDate() async throws {
        let database = ArrayTestDatabase()
        database.append([])

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            let item = try await PerfumeryHistoryLoader.load(
                dateKey: "2028-12-01",
                language: "en",
                on: app.db
            )
            #expect(item == nil)
        }
    }

    @Test("The same stored story is returned in Russian and English")
    func localizedStory() async throws {
        let database = ArrayTestDatabase()
        let entry = try #require(PerfumeryHistorySeed.entries().first)
        database.append([PerfumeryHistoryModel(entry: entry)])
        database.append([PerfumeryHistoryModel(entry: entry)])

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            let russian = try await PerfumeryHistoryLoader.load(
                dateKey: entry.dateKey,
                language: "ru",
                on: app.db
            )
            let english = try await PerfumeryHistoryLoader.load(
                dateKey: entry.dateKey,
                language: "en",
                on: app.db
            )

            #expect(russian?.title == entry.titleRu)
            #expect(russian?.fullStory == entry.fullStoryRu)
            #expect(english?.title == entry.titleEn)
            #expect(english?.fullStory == entry.fullStoryEn)
        }
    }

    @Test("December 1 and 2 return different stored histories")
    func consecutiveDecemberStories() async throws {
        let entries = try PerfumeryHistorySeed.entries()
        let first = try #require(entries.first { $0.dateKey == "2026-12-01" })
        let second = try #require(entries.first { $0.dateKey == "2026-12-02" })
        let database = ArrayTestDatabase()
        database.append([PerfumeryHistoryModel(entry: first)])
        database.append([PerfumeryHistoryModel(entry: second)])

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            let firstResponse = try await PerfumeryHistoryLoader.load(
                dateKey: first.dateKey,
                language: "en",
                on: app.db
            )
            let secondResponse = try await PerfumeryHistoryLoader.load(
                dateKey: second.dateKey,
                language: "en",
                on: app.db
            )

            #expect(firstResponse?.publicationDate == "2026-12-01")
            #expect(secondResponse?.publicationDate == "2026-12-02")
            #expect(firstResponse?.fullStory != secondResponse?.fullStory)
        }
    }

    @Test("The route selects different histories on December 1 and 2")
    func routeChangesAtMidnight() async throws {
        let entries = try PerfumeryHistorySeed.entries()
        let first = try #require(entries.first { $0.dateKey == "2026-12-01" })
        let second = try #require(entries.first { $0.dateKey == "2026-12-02" })
        let models = [
            first.dateKey: PerfumeryHistoryModel(entry: first),
            second.dateKey: PerfumeryHistoryModel(entry: second)
        ]
        let database = CallbackTestDatabase { query in
            let key = models.keys.first { dateKey in
                query.filters.contains { $0.description.contains("\"\(dateKey)\"") }
            }
            guard let key, let model = models[key] else {
                return []
            }
            return [TestOutput(model)]
        }

        for (day, expected) in [(1, first), (2, second)] {
            let instant = try #require(
                ISO8601DateFormatter().date(from: "2026-12-0\(day)T12:00:00Z")
            )
            try await withApp { app in
                app.databases.use(database.configuration, as: .psql)
                try routes(app, historyClock: PerfumeryHistoryClock { instant })
                try await app.testing().test(.GET, "/perfumery-history?timeZone=UTC") { response in
                    #expect(response.status == .ok)
                    let item = try JSONDecoder().decode(
                        PerfumeryHistoryItem.self,
                        from: Data(response.body.string.utf8)
                    )
                    #expect(item.publicationDate == expected.dateKey)
                    #expect(item.fullStory == expected.fullStoryEn)
                }
            }
        }
    }

    @Test("The history endpoint returns 404 when no date is stored")
    func missingRoute() async throws {
        let database = ArrayTestDatabase()
        database.append([])

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(.GET, "/perfumery-history?timeZone=UTC") { response in
                #expect(response.status == .notFound)
            }
        }
    }

    @Test("The history endpoint rejects an invalid time zone")
    func invalidTimeZone() async throws {
        try await withApp { app in
            try routes(app)
            try await app.testing().test(.GET, "/perfumery-history?timeZone=Invalid") { response in
                #expect(response.status == .badRequest)
            }
        }
    }
}
