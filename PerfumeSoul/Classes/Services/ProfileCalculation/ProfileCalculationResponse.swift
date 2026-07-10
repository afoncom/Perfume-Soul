//
//  ProfileCalculationResponse.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct ProfileCalculationResponse: Decodable, Equatable {
    let natalChart: NatalChartResponse
    let elementBalance: ElementBalanceResponse
}

struct NatalChartResponse: Decodable, Equatable {
    let sun: ZodiacPlacementResponse
    let moon: ZodiacPlacementResponse
    let ascendant: ZodiacPlacementResponse
}

struct ZodiacPlacementResponse: Decodable, Equatable {
    let sign: String
    let longitude: Double
}

struct ElementBalanceResponse: Decodable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}
