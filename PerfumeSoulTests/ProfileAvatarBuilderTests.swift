//
//  ProfileAvatarBuilderTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 04.08.2026.
//

import XCTest
@testable import PerfumeSoul

final class ProfileAvatarBuilderTests: XCTestCase {
    private let builder = ProfileAvatarBuilderImpl()

    func testMakeAvatarUsesFirstTwoNameInitials() {
        let avatar = builder.makeAvatar(name: "Dmitry Ivanov")

        XCTAssertEqual(avatar.initials, "DI")
    }

    func testMakeAvatarClampsUppercasedUnicodeInitials() {
        let avatar = builder.makeAvatar(name: "ßeta Öz")

        XCTAssertEqual(avatar.initials, "SS")
    }

    func testMakeAvatarUsesFallbackForEmptyName() {
        let avatar = builder.makeAvatar(name: "   ")

        XCTAssertEqual(avatar.initials, "?")
    }

    func testMakeAvatarUsesDeterministicGradientColors() {
        let firstAvatar = builder.makeAvatar(name: "Maria Elena")
        let secondAvatar = builder.makeAvatar(name: "Maria Elena")

        XCTAssertEqual(firstAvatar.gradientColors, secondAvatar.gradientColors)
        XCTAssertEqual(firstAvatar.gradientColors.count, 2)
    }

    func testMakeAvatarUsesDistinctGradientsForPlaceholderProfiles() {
        // Mirrors the hardcoded names in ProfileScreen.makeAddedNewProfiless(), which render side by side.
        let laura = builder.makeAvatar(name: "Laura").gradientColors
        let alex = builder.makeAvatar(name: "Alex").gradientColors
        let emma = builder.makeAvatar(name: "Emma").gradientColors

        XCTAssertNotEqual(laura, alex)
        XCTAssertNotEqual(alex, emma)
        XCTAssertNotEqual(laura, emma)
    }

    func testMakeAvatarKeysGradientByFullNameInsteadOfInitials() {
        let firstAvatar = builder.makeAvatar(name: "Alex")
        let secondAvatar = builder.makeAvatar(name: "Ada")

        XCTAssertEqual(firstAvatar.initials, secondAvatar.initials)
        XCTAssertNotEqual(firstAvatar.gradientColors, secondAvatar.gradientColors)
    }

    func testMakeAvatarNormalizesNameBeforeHashing() {
        let firstAvatar = builder.makeAvatar(name: "Maria Elena")
        let secondAvatar = builder.makeAvatar(name: "  maria   elena ")

        XCTAssertEqual(firstAvatar.gradientColors, secondAvatar.gradientColors)
    }
}
