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

    func testProfilePreferredZodiacSignUsesCalculatedSunSignBeforeDateFallback() {
        let profile = Profile(
            name: "Test",
            birthDate: "21.06.1996",
            birthTime: "00:30",
            birthPlace: "Belgrade",
            birthLatitude: 44.7866,
            birthLongitude: 20.4489,
            birthTimeZoneIdentifier: "Europe/Belgrade",
            calculatedSunSign: "gemini"
        )

        XCTAssertEqual(profile.zodiacSign(), "cancer")
        XCTAssertEqual(profile.preferredZodiacSign, "gemini")
    }

    func testProfileUsesCachedCalculationWhenBirthInputsMatch() throws {
        let profile = makeProfile().withProfileCalculation(makeProfileCalculation())
        let cachedProfileCalculation = try XCTUnwrap(profile.cachedProfileCalculation)

        XCTAssertEqual(cachedProfileCalculation.natalChart.sun.sign, .cancer)
        XCTAssertEqual(profile.preferredZodiacSign, "cancer")
    }

    func testProfileInvalidatesCachedCalculationWhenBirthInputsChange() {
        let profile = makeProfile().withProfileCalculation(makeProfileCalculation())
        let changedProfile = Profile(
            name: profile.name,
            birthDate: profile.birthDate,
            birthTime: "18:00",
            birthPlace: profile.birthPlace,
            birthLatitude: profile.birthLatitude,
            birthLongitude: profile.birthLongitude,
            birthTimeZoneIdentifier: profile.birthTimeZoneIdentifier,
            calculatedSunSign: profile.calculatedSunSign,
            profileCalculationCacheKey: profile.profileCalculationCacheKey,
            profileCalculationJSON: profile.profileCalculationJSON
        )

        XCTAssertNil(changedProfile.cachedProfileCalculation)
    }

    func testProfileInvalidatesCachedCalculationWhenCacheVersionChanges() {
        let profile = makeProfile().withProfileCalculation(makeProfileCalculation())
        let profileWithOldCacheVersion = Profile(
            name: profile.name,
            birthDate: profile.birthDate,
            birthTime: profile.birthTime,
            birthPlace: profile.birthPlace,
            birthLatitude: profile.birthLatitude,
            birthLongitude: profile.birthLongitude,
            birthTimeZoneIdentifier: profile.birthTimeZoneIdentifier,
            calculatedSunSign: profile.calculatedSunSign,
            profileCalculationCacheKey: profile.profileCalculationCacheKey?.replacingOccurrences(
                of: "profileCalculation:v1",
                with: "profileCalculation:v0"
            ),
            profileCalculationJSON: profile.profileCalculationJSON
        )

        XCTAssertNil(profileWithOldCacheVersion.cachedProfileCalculation)
    }

    func testCalculationViewModelFormatsBirthDateWithGregorianCalendar() throws {
        let viewModel = CalculationViewModel()
        viewModel.birthDate = try makeGregorianDate(year: 1996, month: 7, day: 7)
        viewModel.birthTime = try makeGregorianDate(year: 1996, month: 7, day: 7, hour: 16, minute: 37)

        XCTAssertEqual(viewModel.formattedBirthDate, "07.07.1996")
        XCTAssertEqual(viewModel.formattedBirthTime, "16:37")
    }

    func testCalculationViewModelPrefillsCompleteProfile() {
        let viewModel = CalculationViewModel(initialProfile: makeProfile())

        XCTAssertEqual(viewModel.firstName, "Test")
        XCTAssertEqual(viewModel.formattedBirthDate, "07.07.1996")
        XCTAssertEqual(viewModel.formattedBirthTime, "16:37")
        XCTAssertEqual(viewModel.birthPlace, "Belgrade")
        XCTAssertEqual(viewModel.selectedBirthPlace?.displayName, "Belgrade")
        XCTAssertEqual(viewModel.selectedBirthPlace?.latitude, 44.7866)
        XCTAssertEqual(viewModel.selectedBirthPlace?.longitude, 20.4489)
        XCTAssertEqual(viewModel.selectedBirthPlace?.timeZoneIdentifier, "Europe/Belgrade")
        XCTAssertTrue(viewModel.isContinueEnabled)
    }

    func testCalculationViewModelPrefillsProfileWithoutResolvedBirthPlace() {
        let viewModel = CalculationViewModel(
            initialProfile: Profile(
                name: "Test",
                birthDate: "07.07.1996",
                birthTime: "16:37",
                birthPlace: "Belgrade",
                birthLatitude: nil,
                birthLongitude: nil,
                birthTimeZoneIdentifier: nil
            )
        )

        XCTAssertEqual(viewModel.firstName, "Test")
        XCTAssertEqual(viewModel.formattedBirthDate, "07.07.1996")
        XCTAssertEqual(viewModel.formattedBirthTime, "16:37")
        XCTAssertEqual(viewModel.birthPlace, "Belgrade")
        XCTAssertNil(viewModel.selectedBirthPlace)
        XCTAssertFalse(viewModel.isContinueEnabled)
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

    private func makeProfile() -> Profile {
        Profile(
            name: "Test",
            birthDate: "07.07.1996",
            birthTime: "16:37",
            birthPlace: "Belgrade",
            birthLatitude: 44.7866,
            birthLongitude: 20.4489,
            birthTimeZoneIdentifier: "Europe/Belgrade"
        )
    }

    private func makeProfileCalculation() -> ProfileCalculation {
        ProfileCalculation(
            natalChart: NatalChart(
                sun: ZodiacPlacement(sign: .cancer, longitude: 105.4),
                moon: ZodiacPlacement(sign: .aquarius, longitude: 318.2),
                ascendant: ZodiacPlacement(sign: .libra, longitude: 190.1)
            ),
            elementBalance: ElementBalance(
                fire: 0,
                earth: 0,
                air: 60,
                water: 40
            )
        )
    }
}
