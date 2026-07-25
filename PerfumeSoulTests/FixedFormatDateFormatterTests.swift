//
//  FixedFormatDateFormatterTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 25.07.2026.
//

import Foundation
import XCTest
@testable import PerfumeSoul

final class FixedFormatDateFormatterTests: XCTestCase {
    func testFixedFormatterUsesGregorianYearWhenReferenceLocaleUsesBuddhistCalendar() throws {
        let date = try makeGregorianDate(year: 1996, month: 7, day: 7)

        let buddhistFormatter = DateFormatter()
        buddhistFormatter.locale = Locale(identifier: "th_TH")
        buddhistFormatter.calendar = Calendar(identifier: .buddhist)
        buddhistFormatter.dateFormat = "yyyy-MM-dd"

        let formatter = FixedFormatDateFormatter.make(dateFormat: "yyyy-MM-dd")

        XCTAssertEqual(buddhistFormatter.string(from: date), "2539-07-07")
        XCTAssertEqual(formatter.string(from: date), "1996-07-07")
    }

    func testProfileNormalizesBirthDateWithGregorianCalendar() {
        let profile = Profile(
            name: "Test",
            birthDate: "07.07.1996",
            birthTime: "16:37",
            birthPlace: "Belgrade",
            birthLatitude: 44.7866,
            birthLongitude: 20.4489,
            birthTimeZoneIdentifier: "Europe/Belgrade"
        )

        XCTAssertEqual(profile.normalizedBirthDate, "1996-07-07")
        XCTAssertEqual(profile.zodiacSign(), "cancer")
    }

    func testCalculationViewModelFormatsBirthDateWithGregorianCalendar() throws {
        let viewModel = CalculationViewModel()
        viewModel.birthDate = try makeGregorianDate(year: 1996, month: 7, day: 7)
        viewModel.birthTime = try makeGregorianDate(year: 1996, month: 7, day: 7, hour: 16, minute: 37)

        XCTAssertEqual(viewModel.formattedBirthDate, "07.07.1996")
        XCTAssertEqual(viewModel.formattedBirthTime, "16:37")
    }

    private func makeGregorianDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 0
    ) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current

        return try XCTUnwrap(
            calendar.date(
                from: DateComponents(
                    year: year,
                    month: month,
                    day: day,
                    hour: hour,
                    minute: minute
                )
            )
        )
    }
}
