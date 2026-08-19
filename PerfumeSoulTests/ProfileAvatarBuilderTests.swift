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

        XCTAssertEqual(avatar.initials, "SÖ")
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

    func testMakeAvatarKeepsStableGradientColorsForPlaceholderProfiles() {
        let expected: [String: [ProfileAvatarColor]] = [
            "Laura": [.zodiacPink, .avatarOcean],
            "Alex": [.avatarAmber, .zodiacBlue],
            "Emma": [.zodiacPurple, .zodiacPink]
        ]

        XCTAssertEqual(Set(ProfilePresenterImpl.placeholderProfileNames), Set(expected.keys))

        for (name, colors) in expected {
            XCTAssertEqual(builder.makeAvatar(name: name).gradientColors, colors, name)
        }

        XCTAssertEqual(Set(expected.values).count, expected.count, "Placeholder profile gradients should be distinct")
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
        let precomposedAvatar = builder.makeAvatar(name: "José Álvarez")
        let decomposedAvatar = builder.makeAvatar(name: "Jose\u{301} A\u{301}lvarez")

        XCTAssertEqual(firstAvatar.gradientColors, secondAvatar.gradientColors)
        XCTAssertEqual(precomposedAvatar.gradientColors, decomposedAvatar.gradientColors)
    }
}
