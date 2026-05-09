//
//  DailyHoroscopeService.swift
//  PerfumeSoul
//
//  Created by afon.com on 29.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DailyHoroscopeService {
    func requestDailyHoroscope() async throws -> [DailyHoroscope]
}

final class DailyHoroscopeServiceImpl {
    let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension DailyHoroscopeServiceImpl: DailyHoroscopeService {
    func requestDailyHoroscope() async throws -> [DailyHoroscope] {
        let horoscopes: [DailyHoroscopeResponse] = try await requestManager.sendRequest(request: DailyHoroscopeRequest())
        return horoscopes.map{ DailyHoroscope(response: $0) }
    }
}
