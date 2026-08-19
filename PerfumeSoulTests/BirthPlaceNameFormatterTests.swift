//
//  BirthPlaceNameFormatterTests.swift
//  PerfumeSoulTests
//

import XCTest
@testable import PerfumeSoul

final class BirthPlaceNameFormatterTests: XCTestCase {
    func testFormatKeepsRegionAndCountrySuffix() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: "Springfield",
                subtitle: "Illinois, United States"
            ),
            "Springfield, Illinois, United States"
        )
    }

    func testFormatKeepsSingleSubtitleComponentForDisambiguation() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(title: "Paris", subtitle: "France"),
            "Paris, France"
        )
    }

    func testFormatDoesNotRepeatTheSameComponent() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(title: "Madrid", subtitle: "Madrid"),
            "Madrid"
        )
    }

    func testFormatTreatsDiacriticAndCaseVariantsAsTheSameComponent() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(title: "Zürich", subtitle: "zurich, Switzerland"),
            "Zürich, Switzerland"
        )
    }

    func testFormatDropsLeadingTitleBeforeRegion() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: "Springfield",
                subtitle: "Springfield, Illinois, United States"
            ),
            "Springfield, Illinois, United States"
        )
    }

    func testFormatKeepsCountryAfterDroppingLeadingTitle() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: "Paris",
                subtitle: "Paris, France"
            ),
            "Paris, France"
        )
    }

    func testFormatReturnsSubtitleWhenPrimaryIsEmpty() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: nil,
                subtitle: "Illinois, United States"
            ),
            "Illinois, United States"
        )
    }

    func testPlaceMatchesComponentInsideMultiComponentValue() {
        XCTAssertTrue(BirthPlaceNameFormatter.place("Москва", matchesComponentIn: "Москва, Россия"))
        XCTAssertFalse(BirthPlaceNameFormatter.place("Тверь", matchesComponentIn: "Москва, Россия"))
    }
}
