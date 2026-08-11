import XCTest
@testable import PerfumeSoul

final class SupportedAppLanguageTests: XCTestCase {
    func testCodeKeepsRussianLocalization() {
        XCTAssertEqual(SupportedAppLanguage.code(for: "ru"), "ru")
    }

    func testCodeFallsBackToEnglishForUnsupportedLocalization() {
        XCTAssertEqual(SupportedAppLanguage.code(for: "pt"), "en")
        XCTAssertEqual(SupportedAppLanguage.code(for: nil), "en")
    }
}
