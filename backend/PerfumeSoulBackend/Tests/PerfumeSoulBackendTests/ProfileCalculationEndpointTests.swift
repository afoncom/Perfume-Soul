import Testing
import Vapor
import VaporTesting
@testable import PerfumeSoulBackend

struct ProfileCalculationEndpointTests {
    @Test("POST /profile/calculate returns natal chart and element balance")
    func profileCalculateEndpoint() async throws {
        try await withApp { app in
            try routes(app)

            try await app.testing().test(.POST, "/profile/calculate") { req in
                try req.content.encode(
                    ProfileCalculationRequest(
                        birthDate: "1996-07-07",
                        birthTime: "16:37",
                        latitude: 44.7866,
                        longitude: 20.4489,
                        timeZoneIdentifier: "Europe/Belgrade",
                        altitudeMeters: nil
                    )
                )
            } afterResponse: { res in
                #expect(res.status == .ok)

                let response = try JSONDecoder().decode(
                    ProfileCalculationResponse.self,
                    from: Data(res.body.string.utf8)
                )

                #expect(response.natalChart.sun.sign == .cancer)
                #expect(response.elementBalance.fire >= 0)
                #expect(response.elementBalance.earth >= 0)
                #expect(response.elementBalance.air >= 0)
                #expect(response.elementBalance.water >= 0)
                #expect(
                    response.elementBalance.fire
                    + response.elementBalance.earth
                    + response.elementBalance.air
                    + response.elementBalance.water == 100
                )
            }
        }
    }

    @Test("POST /profile/calculate accepts valid negative coordinates")
    func profileCalculateEndpointAcceptsValidNegativeCoordinates() async throws {
        try await withApp { app in
            try routes(app)

            try await app.testing().test(.POST, "/profile/calculate") { req in
                try req.content.encode(
                    makeRequest(
                        latitude: -33.8688,
                        longitude: -151.2093,
                        timeZoneIdentifier: "Australia/Sydney"
                    )
                )
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
        }
    }

    @Test("POST /profile/calculate rejects invalid API boundary input")
    func profileCalculateEndpointRejectsInvalidInput() async throws {
        let invalidCases = [
            ("invalid date", makeRequest(birthDate: "2000-13-40")),
            ("invalid time", makeRequest(birthTime: "25:90")),
            ("latitude below range", makeRequest(latitude: -90.1)),
            ("latitude above range", makeRequest(latitude: 90.1)),
            ("longitude below range", makeRequest(longitude: -180.1)),
            ("longitude above range", makeRequest(longitude: 180.1)),
            ("invalid time zone", makeRequest(timeZoneIdentifier: "Mars/Olympus")),
            (
                "nonexistent local time",
                makeRequest(
                    birthDate: "2024-03-31",
                    birthTime: "02:30",
                    timeZoneIdentifier: "Europe/Belgrade"
                )
            )
        ]

        for (name, request) in invalidCases {
            try await withApp { app in
                try routes(app)

                try await app.testing().test(.POST, "/profile/calculate") { req in
                    try req.content.encode(request)
                } afterResponse: { res in
                    #expect(res.status == .badRequest, "\(name) should be rejected")
                }
            }
        }
    }

    @Test("POST /profile/calculate accepts ambiguous fall-back local time")
    func profileCalculateEndpointAcceptsAmbiguousFallBackLocalTime() async throws {
        try await withApp { app in
            try routes(app)

            try await app.testing().test(.POST, "/profile/calculate") { req in
                try req.content.encode(
                    makeRequest(
                        birthDate: "2024-10-27",
                        birthTime: "02:30",
                        timeZoneIdentifier: "Europe/Belgrade"
                    )
                )
            } afterResponse: { res in
                #expect(res.status == .ok)
            }
        }
    }
}

private func makeRequest(
    birthDate: String = "1996-07-07",
    birthTime: String = "16:37",
    latitude: Double = 44.7866,
    longitude: Double = 20.4489,
    timeZoneIdentifier: String = "Europe/Belgrade"
) -> ProfileCalculationRequest {
    ProfileCalculationRequest(
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        timeZoneIdentifier: timeZoneIdentifier,
        altitudeMeters: nil
    )
}
