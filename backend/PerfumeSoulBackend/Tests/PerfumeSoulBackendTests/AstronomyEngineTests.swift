import Testing
import Foundation
@testable import PerfumeSoulBackend

struct AstronomyEngineTests {
    @Test("Natal chart returns stable placements for a valid observer input")
    func natalChartForValidInput() throws {
        let input = NatalChartInput(
            year: 1996,
            month: 7,
            day: 7,
            hour: 16,
            minute: 37,
            latitude: 44.7866,
            longitude: 20.4489,
            timeZoneIdentifier: "Europe/Belgrade"
        )

        let chart = try AstronomyEngine.calculateNatalChart(for: input)

        #expect(chart.sun.sign == .cancer)
        #expect((0..<360).contains(chart.sun.longitude))
        #expect((0..<360).contains(chart.moon.longitude))
        #expect((0..<360).contains(chart.ascendant.longitude))
    }

    @Test("Changing observer longitude changes the ascendant result")
    func longitudeAffectsAscendant() throws {
        let madrid = NatalChartInput(
            year: 1996,
            month: 7,
            day: 7,
            hour: 16,
            minute: 37,
            latitude: 40.4168,
            longitude: -3.7038,
            timeZoneIdentifier: "Europe/Madrid"
        )
        let tokyo = NatalChartInput(
            year: 1996,
            month: 7,
            day: 7,
            hour: 16,
            minute: 37,
            latitude: 35.6762,
            longitude: 139.6503,
            timeZoneIdentifier: "Asia/Tokyo"
        )

        let madridChart = try AstronomyEngine.calculateNatalChart(for: madrid)
        let tokyoChart = try AstronomyEngine.calculateNatalChart(for: tokyo)

        #expect(madridChart.ascendant.longitude != tokyoChart.ascendant.longitude)
    }

    @Test("Unknown time zone is rejected")
    func unknownTimeZone() {
        let input = NatalChartInput(
            year: 1996,
            month: 7,
            day: 7,
            hour: 16,
            minute: 37,
            latitude: 44.7866,
            longitude: 20.4489,
            timeZoneIdentifier: "Mars/Olympus"
        )

        #expect(throws: (any Error).self) {
            try AstronomyEngine.calculateNatalChart(for: input)
        }
    }

    @Test("Ambiguous fall-back local time uses first occurrence")
    func ambiguousFallBackLocalTimeUsesFirstOccurrence() throws {
        let timeZone = try #require(TimeZone(identifier: "Europe/Belgrade"))
        let localDate = try #require(
            LocalWallTimeResolver.date(
                year: 2024,
                month: 10,
                day: 27,
                hour: 2,
                minute: 30,
                second: 0,
                timeZone: timeZone
            )
        )

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        let utcComponents = utcCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: localDate
        )

        #expect(utcComponents.year == 2024)
        #expect(utcComponents.month == 10)
        #expect(utcComponents.day == 27)
        #expect(utcComponents.hour == 0)
        #expect(utcComponents.minute == 30)
        #expect(utcComponents.second == 0)
    }
}
