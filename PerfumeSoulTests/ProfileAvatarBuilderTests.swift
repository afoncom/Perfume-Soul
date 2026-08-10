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

    func testMakeAvatarCanUseDifferentGradientColorsForDifferentNames() {
        let firstAvatar = builder.makeAvatar(name: "Maria Elena")
        let secondAvatar = builder.makeAvatar(name: "Dmitry Ivanov")

        XCTAssertNotEqual(firstAvatar.gradientColors, secondAvatar.gradientColors)
    }

    func testMakeAvatarCanUseDifferentGradientColorsForSameInitials() {
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
