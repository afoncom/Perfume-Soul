import Foundation
import XCTest
@testable import PerfumeSoul

final class DailyHoroscopeContractTests: XCTestCase {
    func testRequestSendsCurrentTimeZone() {
        let request = DailyHoroscopeRequest()

        XCTAssertEqual(request.queryItems.count, 1)
        XCTAssertEqual(request.queryItems.first?.name, "timeZone")
        XCTAssertEqual(request.queryItems.first?.value, TimeZone.current.identifier)
    }

    func testResponseDecodesLocalizedDailyText() throws {
        let data = Data(#"[{"sign":"aries","energyOfDay":"Start with one important task today."}]"#.utf8)

        let response = try JSONDecoder().decode([DailyHoroscopeResponse].self, from: data)

        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response.first?.sign, "aries")
        XCTAssertEqual(response.first?.energyOfDay, "Start with one important task today.")
    }
}
