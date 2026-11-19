import Foundation
import XCTest
@testable import PerfumeSoul

final class PerfumeHistoryServiceTests: XCTestCase {
    func testDecodesLocalizedFullStoryWithoutShortStory() async throws {
        let manager = PerfumeHistoryRequestManager(
            responseJSON: #"{"publicationDate":"2026-12-01","eventYear":2020,"title":"A Kimono Translated into Scent","fullStory":"The complete story."}"#
        )
        let service = PerfumeHistoryServiceImpl(requestManager: manager)

        let history = try await service.requestPerfumeHistory()

        XCTAssertEqual(history.publicationDate, "2026-12-01")
        XCTAssertEqual(history.year, 2020)
        XCTAssertEqual(history.title, "A Kimono Translated into Scent")
        XCTAssertEqual(history.fullStory, "The complete story.")
    }

    func testRequestIncludesLocalTimeZone() {
        let request = PerfumeHistoryRequest(timeZoneIdentifier: "Europe/Madrid")

        XCTAssertEqual(request.path, "/v2/perfumery-history")
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "timeZone", value: "Europe/Madrid")])
    }
}

private final class PerfumeHistoryRequestManager: RequestManager {
    private let responseData: Data

    init(responseJSON: String) {
        responseData = Data(responseJSON.utf8)
    }

    func sendRequest<Response: Decodable>(request: Request) async throws -> Response {
        try JSONDecoder().decode(Response.self, from: responseData)
    }
}
