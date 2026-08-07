//
//  ProfileAvatarBuilderTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 04.08.2026.
//

import XCTest
@testable import PerfumeSoul

final class ProfileAvatarBuilderTests: XCTestCase {
    private let builder = ProfileAvatarBuilderImpl()

    func testMakeAvatarUsesFirstTwoNameInitials() {
        let avatar = builder.makeAvatar(name: "Dmitry Ivanov")

        XCTAssertEqual(avatar.initials, "DI")
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
}
