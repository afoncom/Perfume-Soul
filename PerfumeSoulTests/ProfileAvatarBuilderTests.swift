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

}
