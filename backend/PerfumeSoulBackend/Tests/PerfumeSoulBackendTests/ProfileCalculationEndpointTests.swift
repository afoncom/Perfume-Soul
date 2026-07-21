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
}
