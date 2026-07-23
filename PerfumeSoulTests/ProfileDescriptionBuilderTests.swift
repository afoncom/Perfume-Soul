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

    func testElementBalanceProfileKeepsFullSpreadForThreePlacementDistribution() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 34, earth: 33, air: 33, water: 0)
        )

        XCTAssertEqual(profile.dominantElement, .fire)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 34)
    }

    func testElementBalanceProfileSelectsDominantAndWeakByScore() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 10, earth: 55, air: 25, water: 10)
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 45)
    }

    func testElementBalanceProfileUsesStableTieBreakers() {
        let profile = builder.makeElementBalanceProfile(
            from: ElementBalance(fire: 0, earth: 50, air: 50, water: 0)
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertEqual(profile.weakElement, .water)
        XCTAssertEqual(profile.spread, 50)
    }

    func testBuildUsesBalancedSynthesisForRealizableThreeElementDistribution() {
        let description = builder.build(
            profile: makeProfile(),
            calculation: ProfileCalculation(
                natalChart: NatalChart(
                    sun: ZodiacPlacement(longitude: 0),
                    moon: ZodiacPlacement(longitude: 30),
                    ascendant: ZodiacPlacement(longitude: 60)
                ),
                elementBalance: ElementBalance(fire: 40, earth: 28, air: 32, water: 0)
            )
        )
        let expectedSummary = Bundle.main.localizedString(
            forKey: "profileDescription.synthesis.balanced.summary",
            value: nil,
            table: nil
        )

        XCTAssertEqual(description.summary, expectedSummary)
    }

    func testBuildDoesNotUseBalancedSynthesisForRepeatedElementDistribution() {
        let description = builder.build(
            profile: makeProfile(),
            calculation: ProfileCalculation(
                natalChart: NatalChart(
                    sun: ZodiacPlacement(longitude: 0),
                    moon: ZodiacPlacement(longitude: 30),
                    ascendant: ZodiacPlacement(longitude: 150)
                ),
                elementBalance: ElementBalance(fire: 40, earth: 60, air: 0, water: 0)
            )
        )
        let expectedSummary = Bundle.main.localizedString(
            forKey: "profileDescription.synthesis.visibleEmotional.summary",
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
