//
//  PersonalPerfumeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumeService {
    func requestPersonalPerfumes(profile: PersonalPerfumeProfileRequest) async throws -> [PersonalPerfumeResponse]
}

final class PersonalPerfumeServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension PersonalPerfumeServiceImpl: PersonalPerfumeService {
    func requestPersonalPerfumes(profile: PersonalPerfumeProfileRequest) async throws -> [PersonalPerfumeResponse] {
        try await requestManager.sendRequest(
            request: PersonalPerfumeRequest(profile: profile)
        )
    }
}
