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
        try validateCoordinates()
        try validateTimeZoneIdentifier()

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
        let components = birthDate.split(separator: "-", omittingEmptySubsequences: false)
        guard
            birthDate.count == 10,
            components.count == 3,
            components[0].count == 4,
            components[1].count == 2,
            components[2].count == 2,
            let year = Int(components[0]),
            let month = Int(components[1]),
            let day = Int(components[2])
        else {
            throw Abort(.badRequest, reason: "birthDate must use yyyy-MM-dd format.")
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        let dateComponents = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        )

        guard let date = calendar.date(from: dateComponents) else {
            throw Abort(.badRequest, reason: "birthDate must be a valid calendar date.")
        }

        let resolvedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        guard
            (1...9999).contains(year),
            resolvedComponents.year == year,
            resolvedComponents.month == month,
            resolvedComponents.day == day
        else {
            throw Abort(.badRequest, reason: "birthDate must be a valid calendar date.")
        }

        return (year, month, day)
    }

    func parseBirthTime() throws -> (hour: Int, minute: Int) {
        let components = birthTime.split(separator: ":", omittingEmptySubsequences: false)
        guard
            birthTime.count == 5,
            components.count == 2,
            components[0].count == 2,
            components[1].count == 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            throw Abort(.badRequest, reason: "birthTime must use HH:mm format.")
        }

        guard (0...23).contains(hour), (0...59).contains(minute) else {
            throw Abort(.badRequest, reason: "birthTime must be a valid 24-hour time.")
        }

        return (hour, minute)
    }

    func validateCoordinates() throws {
        guard (-90...90).contains(latitude) else {
            throw Abort(.badRequest, reason: "latitude must be between -90 and 90.")
        }

        guard (-180...180).contains(longitude) else {
            throw Abort(.badRequest, reason: "longitude must be between -180 and 180.")
        }
    }

    func validateTimeZoneIdentifier() throws {
        guard TimeZone(identifier: timeZoneIdentifier) != nil else {
            throw Abort(.badRequest, reason: "timeZoneIdentifier must be a valid IANA time zone identifier.")
        }
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
