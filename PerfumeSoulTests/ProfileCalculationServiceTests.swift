//
//  ProfileCalculationServiceTests.swift
//  PerfumeSoulTests
//
//  Created by Codex on 21.07.2026.
//

import Foundation
import XCTest
@testable import PerfumeSoul

final class ProfileCalculationServiceTests: XCTestCase {
    func testCalculateCallsBackendProfileCalculateEndpoint() async throws {
        let requestManager = CapturingRequestManager(
            responseJSON: #"""
            {"natalChart":{"sun":{"sign":"cancer","longitude":105.4},"moon":{"sign":"aquarius","longitude":318.2},"ascendant":{"sign":"libra","longitude":190.1}},"elementBalance":{"fire":0,"earth":0,"air":60,"water":40}}
            """#
        )
        let service = ProfileCalculationServiceImpl(requestManager: requestManager)

        let calculation = try await service.calculate(profile: makeProfile())

        XCTAssertEqual(requestManager.capturedRequest?.path, "/profile/calculate")
        XCTAssertEqual(requestManager.capturedRequest?.httpMethod, .post)
        XCTAssertEqual(calculation.natalChart.sun.sign, .cancer)
        XCTAssertEqual(calculation.natalChart.moon.sign, .aquarius)
        XCTAssertEqual(calculation.natalChart.ascendant.sign, .libra)
        XCTAssertEqual(calculation.elementBalance.air, 60)
        XCTAssertEqual(calculation.elementBalance.water, 40)

        let body = try XCTUnwrap(requestManager.capturedRequest?.jsonBody)
        XCTAssertEqual(body["birthDate"] as? String, "1996-07-07")
        XCTAssertEqual(body["birthTime"] as? String, "16:37")
        XCTAssertEqual(body["latitude"] as? Double, 44.7866)
        XCTAssertEqual(body["longitude"] as? Double, 20.4489)
        XCTAssertEqual(body["timeZoneIdentifier"] as? String, "Europe/Belgrade")
    }

    func testCalculateRejectsProfileWithoutCompleteBirthPlaceData() async throws {
        let requestManager = CapturingRequestManager(responseJSON: "{}")
        let service = ProfileCalculationServiceImpl(requestManager: requestManager)

        do {
            _ = try await service.calculate(
                profile: Profile(
                    name: "Test",
                    birthDate: "07.07.1996",
                    birthTime: "16:37",
                    birthPlace: "Belgrade",
                    birthLatitude: nil,
                    birthLongitude: 20.4489,
                    birthTimeZoneIdentifier: "Europe/Belgrade"
                )
            )
            XCTFail("Expected invalid profile data error")
        } catch ProfileCalculationError.invalidProfileData {
            XCTAssertNil(requestManager.capturedRequest)
        }
    }

    private func makeProfile() -> Profile {
        Profile(
            name: "Test",
            birthDate: "07.07.1996",
            birthTime: "16:37",
            birthPlace: "Belgrade",
            birthLatitude: 44.7866,
            birthLongitude: 20.4489,
            birthTimeZoneIdentifier: "Europe/Belgrade"
        )
    }
}

private final class CapturingRequestManager: RequestManager {
    private let responseData: Data
    private(set) var capturedRequest: Request?

    init(responseJSON: String) {
        self.responseData = Data(responseJSON.utf8)
    }

    func sendRequest<Response: Decodable>(request: Request) async throws -> Response {
        capturedRequest = request
        return try JSONDecoder().decode(Response.self, from: responseData)
    }
}

extension Request {
    fileprivate var jsonBody: [String: Any]? {
        guard let httpBody else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any]
    }
}
