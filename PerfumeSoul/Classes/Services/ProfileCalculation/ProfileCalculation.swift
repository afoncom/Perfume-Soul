//
//  ProfileCalculation.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct ProfileCalculation: Equatable {
    let natalChart: NatalChart
    let elementBalance: ElementBalance
}

struct NatalChart: Equatable {
    let sun: ZodiacPlacement
    let moon: ZodiacPlacement
    let ascendant: ZodiacPlacement
}

struct ZodiacPlacement: Equatable {
    let sign: String
    let longitude: Double
}

struct ElementBalance: Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}

extension ProfileCalculation {
    init(response: ProfileCalculationResponse) {
        self.natalChart = NatalChart(response: response.natalChart)
        self.elementBalance = ElementBalance(response: response.elementBalance)
    }
}

private extension NatalChart {
    init(response: NatalChartResponse) {
        self.sun = ZodiacPlacement(response: response.sun)
        self.moon = ZodiacPlacement(response: response.moon)
        self.ascendant = ZodiacPlacement(response: response.ascendant)
    }
}

private extension ZodiacPlacement {
    init(response: ZodiacPlacementResponse) {
        self.sign = response.sign
        self.longitude = response.longitude
    }
}

private extension ElementBalance {
    init(response: ElementBalanceResponse) {
        self.fire = response.fire
        self.earth = response.earth
        self.air = response.air
        self.water = response.water
    }
}
