//
//  DailyHoroscopeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DailyHoroscopeService {
    func requestDailyHoroscope() async throws
}

final class DailyHoroscopeServiceImpl {
    let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension DailyHoroscopeServiceImpl: DailyHoroscopeService {
    func requestDailyHoroscope() async throws {
        try await requestManager.sendRequest(request: DailyHoroscopeRequest())
    }
}
