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
        let request = try ProfileCalculationRequest(profile: profile)
        let response: ProfileCalculationResponse = try await requestManager.sendRequest(request: request)
        return ProfileCalculation(response: response)
    }
}
