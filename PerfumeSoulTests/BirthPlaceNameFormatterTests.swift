//
//  BirthPlaceNameFormatterTests.swift
//  PerfumeSoulTests
//

import XCTest
@testable import PerfumeSoul

final class BirthPlaceNameFormatterTests: XCTestCase {
    func testFormatKeepsRegionAndDropsCountrySuffix() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: "Springfield",
                subtitle: "Illinois, United States"
            ),
            "Springfield, Illinois"
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

    func testFormatDropsLeadingTitleBeforeRegion() {
        XCTAssertEqual(
            BirthPlaceNameFormatter.format(
                title: "Springfield",
                subtitle: "Springfield, Illinois, United States"
            ),
            "Springfield, Illinois"
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
}
