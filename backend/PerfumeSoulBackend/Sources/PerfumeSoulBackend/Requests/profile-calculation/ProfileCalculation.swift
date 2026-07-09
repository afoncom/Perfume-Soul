import Foundation
import Vapor

struct ProfileCalculationRequest: Content {
    let birthDate: String
    let birthTime: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
    let altitudeMeters: Double?
}

struct ProfileCalculationResponse: Codable, Equatable {
    let natalChart: NatalChart
    let elementBalance: ElementBalance
}

struct ElementBalance: Codable, Equatable {
    let fire: Int
    let earth: Int
    let air: Int
    let water: Int
}

enum ProfileCalculationLoader {
    static func load(request: ProfileCalculationRequest) throws -> ProfileCalculationResponse {
        let input = try request.makeNatalChartInput()
        let natalChart = try AstronomyEngine.calculateNatalChart(for: input)
        let elementBalance = makeElementBalance(for: natalChart)

        return ProfileCalculationResponse(
            natalChart: natalChart,
            elementBalance: elementBalance
        )
    }
}

private extension ProfileCalculationLoader {
    static let placementWeights: [(KeyPath<NatalChart, ZodiacPlacement>, Double)] = [
        (\.sun, 1.0),
        (\.moon, 0.7),
        (\.ascendant, 0.8)
    ]

    static func makeElementBalance(for natalChart: NatalChart) -> ElementBalance {
        var weightsByElement: [ZodiacElement: Double] = [:]

        for (keyPath, weight) in placementWeights {
            let placement = natalChart[keyPath: keyPath]
            weightsByElement[placement.sign.element, default: 0] += weight
        }

        let percentages = normalizedPercentages(from: weightsByElement)

        return ElementBalance(
            fire: percentages[.fire, default: 0],
            earth: percentages[.earth, default: 0],
            air: percentages[.air, default: 0],
            water: percentages[.water, default: 0]
        )
    }

    static func normalizedPercentages(
        from weightsByElement: [ZodiacElement: Double]
    ) -> [ZodiacElement: Int] {
        let totalWeight = weightsByElement.values.reduce(0, +)
        guard totalWeight > 0 else {
            return Dictionary(uniqueKeysWithValues: ZodiacElement.allCases.map { ($0, 0) })
        }

        let exactValues = ZodiacElement.allCases.map { element in
            let weight = weightsByElement[element, default: 0]
            return (element: element, exact: weight / totalWeight * 100)
        }

        var roundedValues = Dictionary(
            uniqueKeysWithValues: exactValues.map { value in
                (value.element, Int(floor(value.exact)))
            }
        )

        let assignedValue = roundedValues.values.reduce(0, +)
        let remainingValue = max(100 - assignedValue, 0)

        let prioritizedRemainders = exactValues.sorted { lhs, rhs in
            let lhsRemainder = lhs.exact - floor(lhs.exact)
            let rhsRemainder = rhs.exact - floor(rhs.exact)

            if lhsRemainder == rhsRemainder {
                return lhs.element.priority < rhs.element.priority
            }

            return lhsRemainder > rhsRemainder
        }

        for index in 0..<remainingValue {
            let element = prioritizedRemainders[index].element
            roundedValues[element, default: 0] += 1
        }

        return roundedValues
    }
}

private extension ProfileCalculationRequest {
    func makeNatalChartInput() throws -> NatalChartInput {
        let dateComponents = try parseBirthDate()
        let timeComponents = try parseBirthTime()

        return NatalChartInput(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier,
            altitudeMeters: altitudeMeters ?? 0
        )
    }

    func parseBirthDate() throws -> (year: Int, month: Int, day: Int) {
        let components = birthDate.split(separator: "-")
        guard
            components.count == 3,
            let year = Int(components[0]),
            let month = Int(components[1]),
            let day = Int(components[2])
        else {
            throw ProfileCalculationLoaderError.invalidBirthDateFormat
        }

        return (year, month, day)
    }

    func parseBirthTime() throws -> (hour: Int, minute: Int) {
        let components = birthTime.split(separator: ":")
        guard
            components.count == 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            throw ProfileCalculationLoaderError.invalidBirthTimeFormat
        }

        return (hour, minute)
    }
}

private extension ZodiacSign {
    var element: ZodiacElement {
        switch self {
        case .aries, .leo, .sagittarius:
            .fire
        case .taurus, .virgo, .capricorn:
            .earth
        case .gemini, .libra, .aquarius:
            .air
        case .cancer, .scorpio, .pisces:
            .water
        }
    }
}

private enum ZodiacElement: CaseIterable {
    case fire
    case earth
    case air
    case water

    var priority: Int {
        switch self {
        case .fire: 0
        case .earth: 1
        case .air: 2
        case .water: 3
        }
    }
}

private enum ProfileCalculationLoaderError: LocalizedError {
    case invalidBirthDateFormat
    case invalidBirthTimeFormat

    var errorDescription: String? {
        switch self {
        case .invalidBirthDateFormat:
            "birthDate must use yyyy-MM-dd format."
        case .invalidBirthTimeFormat:
            "birthTime must use HH:mm format."
        }
    }
}
