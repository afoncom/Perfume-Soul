//
//  BirthPlaceSearchPassResolverTests.swift
//  PerfumeSoulTests
//

import XCTest
@testable import PerfumeSoul

final class BirthPlaceSearchPassResolverTests: XCTestCase {
    func testOutcomeWaitsForEmptyResultsWhileSearching() {
        XCTAssertEqual(
            BirthPlaceSearchPassResolver.outcome(
                isEmpty: true,
                isSearching: true,
                isQueryFallback: false
            ),
            .wait
        )
    }

    func testOutcomeWaitsForPartialResultsWhileSearching() {
        XCTAssertEqual(
            BirthPlaceSearchPassResolver.outcome(
                isEmpty: false,
                isSearching: true,
                isQueryFallback: false
            ),
            .wait
        )
    }

    func testOutcomeEscalatesSettledEmptyAddressPass() {
        XCTAssertEqual(
            BirthPlaceSearchPassResolver.outcome(
                isEmpty: true,
                isSearching: false,
                isQueryFallback: false
            ),
            .escalate
        )
    }

    func testOutcomeResumesSettledEmptyFallbackPass() {
        XCTAssertEqual(
            BirthPlaceSearchPassResolver.outcome(
                isEmpty: true,
                isSearching: false,
                isQueryFallback: true
            ),
            .resume
        )
    }

    func testOutcomeResumesSettledNonEmptyPass() {
        XCTAssertEqual(
            BirthPlaceSearchPassResolver.outcome(
                isEmpty: false,
                isSearching: false,
                isQueryFallback: false
            ),
            .resume
        )
    }
}
