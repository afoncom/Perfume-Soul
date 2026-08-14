//
//  AppVersionProviderTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 11.08.2026.
//

import XCTest
@testable import PerfumeSoul

final class AppVersionProviderTests: XCTestCase {
    func testCurrentAppVersionResolvesFromAppBundle() {
        XCTAssertNotNil(AppVersionProviderImpl().currentAppVersion())
    }
}
