//
//  ProfileCalculationService.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

protocol ProfileCalculationService {
    func calculate(profile: Profile) async throws -> ProfileCalculation
}

final class ProfileCalculationServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension ProfileCalculationServiceImpl: ProfileCalculationService {
    func calculate(profile: Profile) async throws -> ProfileCalculation {
        try await requestManager.sendRequest(request: ProfileCalculationRequest(profile: profile))
    }
}

struct ProfileCalculationRequest: Request {
    let path: String = "/profile/calculate"
    let httpMethod: HTTPMethod = .post
    let httpBody: Data?

    init(profile: Profile) throws {
        guard
            let birthDate = profile.normalizedBirthDate,
            let latitude = profile.birthLatitude,
            let longitude = profile.birthLongitude,
            let timeZoneIdentifier = profile.birthTimeZoneIdentifier
        else {
            throw ProfileCalculationError.invalidProfileData
        }

        let requestBody = ProfileCalculationRequestBody(
            birthDate: birthDate,
            birthTime: profile.birthTime,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier
        )

        self.httpBody = try JSONEncoder().encode(requestBody)
    }
}

private struct ProfileCalculationRequestBody: Encodable {
    let birthDate: String
    let birthTime: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
}

enum ProfileCalculationError: Error {
    case invalidProfileData
}
