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

    init(longitude: Double) {
        self.longitude = Self.normalize(longitude)
        self.sign = ZodiacSign(longitude: longitude)
    }
}

struct ElementBalance: Decodable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int

    init(fire: Double, earth: Double, air: Double, water: Double) {
        let total = fire + earth + air + water

        guard total > 0 else {
            self.fire = 0
            self.earth = 0
            self.air = 0
            self.water = 0
            return
        }

        let rawFire = fire / total * 100
        let rawEarth = earth / total * 100
        let rawAir = air / total * 100
        let rawWater = water / total * 100

        let roundedFire = Int(rawFire.rounded())
        let roundedEarth = Int(rawEarth.rounded())
        let roundedAir = Int(rawAir.rounded())
        let roundedWater = Int(rawWater.rounded())
        let difference = 100 - (roundedFire + roundedEarth + roundedAir + roundedWater)

        self.fire = roundedFire + difference
        self.earth = roundedEarth
        self.air = roundedAir
        self.water = roundedWater
    }
}

extension ZodiacPlacement {
    fileprivate static func normalize(_ longitude: Double) -> Double {
        let remainder = longitude.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }
}
