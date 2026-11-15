import Foundation
import Testing
@testable import PerfumeSoulBackend

struct DailyHoroscopeCalendarTests {
    @Test("The supplied catalog covers every day with twelve localized signs")
    func catalogCoverage() throws {
        let days = try DailyHoroscopeSeed.days()
        let byDate = Dictionary(uniqueKeysWithValues: days.map { ($0.date, $0) })

        #expect(days.count == 731)
        #expect(byDate.count == 731)
        #expect(days.first?.date == "2026-12-01")
        #expect(days.last?.date == "2028-11-30")
        #expect(byDate["2028-02-29"] != nil)
        #expect(byDate["2028-12-01"] == nil)
        #expect(days.allSatisfy { $0.signs.count == 12 })
        #expect(days.allSatisfy { day in
            day.signs.values.allSatisfy { !$0.ru.isEmpty && !$0.en.isEmpty }
        })
        #expect(byDate["2026-12-01"]?.signs["aries"]?.ru != byDate["2026-12-02"]?.signs["aries"]?.ru)
    }

    @Test("The date key follows the requested time zone at New Year")
    func localDateKey() throws {
        let instant = try #require(ISO8601DateFormatter().date(from: "2027-01-01T00:30:00Z"))
        let madrid = try #require(TimeZone(identifier: "Europe/Madrid"))
        let losAngeles = try #require(TimeZone(identifier: "America/Los_Angeles"))

        #expect(DailyHoroscopeCalendar.dateKey(now: instant, timeZone: madrid) == "2027-01-01")
        #expect(DailyHoroscopeCalendar.dateKey(now: instant, timeZone: losAngeles) == "2026-12-31")
    }
}
