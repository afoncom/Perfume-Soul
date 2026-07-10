//
//  ProfileCalculationRequest.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct ProfileCalculationRequest: Request {
    let path: String = "/profile/calculate"
    let httpMethod: HTTPMethod = .post

    private let payload: Payload

    init(profile: Profile) throws {
        guard
            let birthDate = profile.normalizedBirthDate,
            let latitude = profile.birthLatitude,
            let longitude = profile.birthLongitude,
            let timeZoneIdentifier = profile.birthTimeZoneIdentifier
        else {
            throw ProfileCalculationRequestError.invalidProfileData
        }

        self.payload = Payload(
            birthDate: birthDate,
            birthTime: profile.birthTime,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier,
            altitudeMeters: nil
        )
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var httpBody: Data? {
        try? JSONEncoder().encode(payload)
    }
}

private extension ProfileCalculationRequest {
    struct Payload: Encodable {
        let birthDate: String
        let birthTime: String
        let latitude: Double
        let longitude: Double
        let timeZoneIdentifier: String
        let altitudeMeters: Double?
    }
}

enum ProfileCalculationRequestError: Error {
    case invalidProfileData
}
