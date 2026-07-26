//
//  ProfileCalculation.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct ProfileCalculation: Decodable, Equatable {
    let natalChart: NatalChart
    let elementBalance: ElementBalance
}

struct NatalChart: Decodable, Equatable {
    let sun: ZodiacPlacement
    let moon: ZodiacPlacement
    let ascendant: ZodiacPlacement
}

struct ZodiacPlacement: Decodable, Equatable {
    let sign: ZodiacSign
    let longitude: Double
}

struct ElementBalance: Decodable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}
