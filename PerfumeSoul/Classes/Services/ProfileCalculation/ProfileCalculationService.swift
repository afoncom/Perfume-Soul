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
}

extension ProfileCalculationServiceImpl: ProfileCalculationService {
    func calculate(profile: Profile) async throws -> ProfileCalculation {
        let input = try makeNatalChartInput(profile: profile)
        let natalChart = try AstronomyEngine.calculateNatalChart(for: input)
        let elementBalance = makeElementBalance(from: natalChart)

        return ProfileCalculation(
            natalChart: natalChart,
            elementBalance: elementBalance
        )
    }
}

private extension ProfileCalculationServiceImpl {
    func makeNatalChartInput(profile: Profile) throws -> NatalChartInput {
        guard
            let birthDate = profile.normalizedBirthDate,
            let latitude = profile.birthLatitude,
            let longitude = profile.birthLongitude,
            let timeZoneIdentifier = profile.birthTimeZoneIdentifier
        else {
            throw ProfileCalculationError.invalidProfileData
        }

        let birthDateComponents = birthDate.split(separator: "-").compactMap { Int($0) }
        let birthTimeComponents = profile.birthTime.split(separator: ":").compactMap { Int($0) }

        guard
            birthDateComponents.count == 3,
            birthTimeComponents.count == 2
        else {
            throw ProfileCalculationError.invalidProfileData
        }

        return NatalChartInput(
            year: birthDateComponents[0],
            month: birthDateComponents[1],
            day: birthDateComponents[2],
            hour: birthTimeComponents[0],
            minute: birthTimeComponents[1],
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier
        )
    }

    func makeElementBalance(from natalChart: NatalChart) -> ElementBalance {
        let placements: [(ZodiacPlacement, Double)] = [
            (natalChart.sun, 1.0),
            (natalChart.moon, 0.7),
            (natalChart.ascendant, 0.8)
        ]

        var fire = 0.0
        var earth = 0.0
        var air = 0.0
        var water = 0.0

        for (placement, weight) in placements {
            switch placement.sign.element {
            case .fire:
                fire += weight
            case .earth:
                earth += weight
            case .air:
                air += weight
            case .water:
                water += weight
            }
        }

        return ElementBalance(
            fire: fire,
            earth: earth,
            air: air,
            water: water
        )
    }
}

private enum ProfileCalculationError: Error {
    case invalidProfileData
}
