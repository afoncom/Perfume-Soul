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

    func testElementBalanceProfileOmitsWeakElementWhenMinimumIsTied() throws {
        let profile = builder.makeElementBalanceProfile(
            from: try makeCalculation(fire: 100, earth: 0, air: 0, water: 0).elementBalance
        )

        XCTAssertEqual(profile.dominantElement, .fire)
        XCTAssertNil(profile.weakElement)
    }

    func testElementBalanceProfileSelectsUniqueWeakElementByScore() throws {
        let profile = builder.makeElementBalanceProfile(
            from: try makeCalculation(fire: 12, earth: 55, air: 25, water: 8).elementBalance
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertEqual(profile.weakElement, .water)
    }

    func testElementBalanceProfileOmitsWeakElementForTiedZeroMinimum() throws {
        let profile = builder.makeElementBalanceProfile(
            from: try makeCalculation(fire: 0, earth: 50, air: 50, water: 0).elementBalance
        )

        XCTAssertEqual(profile.dominantElement, .earth)
        XCTAssertNil(profile.weakElement)
    }

    func testBuildOmitsWeakElementInsightWhenMinimumIsTied() throws {
        let description = builder.build(
            profile: makeProfile(),
            calculation: try makeCalculation(
                sun: .aries,
                moon: .leo,
                ascendant: .sagittarius,
                fire: 100,
                earth: 0,
                air: 0,
                water: 0
            )
        )

        XCTAssertFalse(description.insights.contains { $0.style == .weakElement })
    }

    func testBuildUsesBalancedSynthesisForRealizableThreeElementDistribution() throws {
        let description = builder.build(
            profile: makeProfile(),
            calculation: try makeCalculation(
                sun: .aries,
                moon: .taurus,
                ascendant: .gemini,
                fire: 40,
                earth: 28,
                air: 32,
                water: 0
            )
        )
        let expectedSummary = Bundle.main.localizedString(
            forKey: "profileDescription.synthesis.balanced.summary",
            value: nil,
            table: nil
        )

        XCTAssertEqual(description.summary, expectedSummary)
    }

    func testBuildDoesNotUseBalancedSynthesisForRepeatedElementDistribution() throws {
        let description = builder.build(
            profile: makeProfile(),
            calculation: try makeCalculation(
                sun: .aries,
                moon: .taurus,
                ascendant: .virgo,
                fire: 40,
                earth: 60,
                air: 0,
                water: 0
            )
        )
        let expectedSummary = Bundle.main.localizedString(
            forKey: "profileDescription.synthesis.visibleEmotional.summary",
            value: nil,
            table: nil
        )

        XCTAssertEqual(description.summary, expectedSummary)
    }

    private func makeCalculation(
        sun: ZodiacSign = .aries,
        moon: ZodiacSign = .taurus,
        ascendant: ZodiacSign = .gemini,
        fire: Int,
        earth: Int,
        air: Int,
        water: Int
    ) throws -> ProfileCalculation {
        let json = """
        {
            "natalChart": {
                "sun": { "sign": "\(sun.rawValue)", "longitude": 0 },
                "moon": { "sign": "\(moon.rawValue)", "longitude": 30 },
                "ascendant": { "sign": "\(ascendant.rawValue)", "longitude": 60 }
            },
            "elementBalance": {
                "fire": \(fire),
                "earth": \(earth),
                "air": \(air),
                "water": \(water)
            }
        }
        """

        return try JSONDecoder().decode(ProfileCalculation.self, from: Data(json.utf8))
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
