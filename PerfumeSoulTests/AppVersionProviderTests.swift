//
//  AppVersionProviderTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 11.08.2026.
//

import XCTest
@testable import PerfumeSoul

final class AppVersionProviderTests: XCTestCase {
    func testCurrentAppVersionResolvesFromAppBundle() throws {
        let version = try XCTUnwrap(AppVersionProviderImpl().currentAppVersion())

        XCTAssertFalse(version.contains("$("), "CFBundleShortVersionString was not substituted: \(version)")
    }
}
