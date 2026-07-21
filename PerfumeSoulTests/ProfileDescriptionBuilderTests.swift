//
//  ProfileDescriptionBuilderTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 21.07.2026.
//

import XCTest
@testable import PerfumeSoul

final class ProfileDescriptionBuilderTests: XCTestCase {
    private let builder = ProfileDescriptionBuilderImpl()

    func testElementBalanceProfileTreatsSmallSpreadAsBalanced() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 28, earth: 24, air: 25, water: 23)
        )

        XCTAssertEqual(profile.dominantElement, .fire)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 5)
        XCTAssertTrue(profile.isBalanced)
    }

    func testElementBalanceProfileDoesNotTreatThreePlacementDistributionAsBalanced() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 34, earth: 33, air: 33, water: 0)
        )

        XCTAssertEqual(profile.dominantElement, .fire)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 34)
        XCTAssertFalse(profile.isBalanced)
    }

    func testElementBalanceProfileSelectsDominantAndWeakByScore() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 10, earth: 55, air: 25, water: 10)
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 45)
        XCTAssertFalse(profile.isBalanced)
    }

    func testElementBalanceProfileUsesStableTieBreakers() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 0, earth: 50, air: 50, water: 0)
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 50)
        XCTAssertFalse(profile.isBalanced)
    }

    func testBuildUsesSpreadBasedBalancedSynthesis() {
        let description = builder.build(
            profile: makeProfile(),
            calculation: ProfileCalculation(
                natalChart: NatalChart(
                    sun: ZodiacPlacement(longitude: 0),
                    moon: ZodiacPlacement(longitude: 30),
                    ascendant: ZodiacPlacement(longitude: 90)
                ),
                elementBalance: ElementBalance(fire: 28, earth: 24, air: 25, water: 23)
            )
        )
        let expectedSummary = Bundle.main.localizedString(
            forKey: "profileDescription.synthesis.balanced.summary",
            value: nil,
            table: nil
        )

        XCTAssertEqual(description.summary, expectedSummary)
    }

    private func makeProfile() -> Profile {
        Profile(
            name: "Test",
            birthDate: "01.01.2000",
            birthTime: "12:00",
            birthPlace: "Madrid",
            birthLatitude: 40.4168,
            birthLongitude: -3.7038,
            birthTimeZoneIdentifier: "Europe/Madrid"
        )
    }
}
