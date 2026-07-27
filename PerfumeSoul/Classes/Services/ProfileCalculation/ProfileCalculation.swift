//
//  ProfileCalculation.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct ProfileCalculation: Codable, Equatable {
    let natalChart: NatalChart
    let elementBalance: ElementBalance
}

struct NatalChart: Codable, Equatable {
    let sun: ZodiacPlacement
    let moon: ZodiacPlacement
    let ascendant: ZodiacPlacement
}

struct ZodiacPlacement: Codable, Equatable {
    let sign: ZodiacSign
    let longitude: Double
}

struct ElementBalance: Codable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}
