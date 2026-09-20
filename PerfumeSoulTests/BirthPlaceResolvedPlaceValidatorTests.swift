//
//  BirthPlaceResolvedPlaceValidatorTests.swift
//  PerfumeSoulTests
//

import XCTest
@testable import PerfumeSoul

final class BirthPlaceResolvedPlaceValidatorTests: XCTestCase {
    func testAllowsGeographicPlaceKinds() {
        let places = [
            BirthPlaceResolvedPlace(locality: "Москва"),
            BirthPlaceResolvedPlace(locality: "Smallville"),
            BirthPlaceResolvedPlace(subLocality: "Тверца"),
            BirthPlaceResolvedPlace(administrativeArea: "Московская область"),
            BirthPlaceResolvedPlace(country: "Россия")
        ]

        for place in places {
            XCTAssertTrue(BirthPlaceResolvedPlaceValidator.isSupported(place))
        }
    }

    func testRejectsPointOfInterestEvenWhenItHasLocality() {
        let place = BirthPlaceResolvedPlace(
            locality: "Москва",
            isPointOfInterest: true
        )

        XCTAssertFalse(BirthPlaceResolvedPlaceValidator.isSupported(place))
    }

    func testRejectsStreetLevelAddressEvenWhenItHasCountry() {
        let place = BirthPlaceResolvedPlace(
            country: "Россия",
            hasStreetAddress: true
        )

        XCTAssertFalse(BirthPlaceResolvedPlaceValidator.isSupported(place))
    }

    func testRejectsPlaceWithoutGeographicComponent() {
        XCTAssertFalse(BirthPlaceResolvedPlaceValidator.isSupported(.init()))
    }
}
