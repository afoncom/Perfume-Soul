import Foundation
import XCTest
@testable import PerfumeSoul

final class DailyPerfumeRequestTests: XCTestCase {
    func testRequestPreservesDistinctFireAndAirValuesInJSON() throws {
        let calculation = ProfileCalculation(
            natalChart: NatalChart(
                sun: ZodiacPlacement(sign: .aries, longitude: 0),
                moon: ZodiacPlacement(sign: .taurus, longitude: 30),
                ascendant: ZodiacPlacement(sign: .gemini, longitude: 60)
            ),
            elementBalance: ElementBalance(fire: 10, earth: 20, air: 30, water: 40)
        )
        let request = DailyPerfumeRequest(
            profile: DailyPerfumeProfile(calculation: calculation),
            excludedPerfumeIDs: [],
            lastShownBrand: nil,
            limit: 1
        )

        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        let balance = try XCTUnwrap(json["elementBalance"] as? [String: Int])

        XCTAssertEqual(balance, ["fire": 10, "earth": 20, "air": 30, "water": 40])
    }
}
