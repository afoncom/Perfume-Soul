//
//  AstronomyEngine.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

enum AstronomyEngine {
    static func calculateNatalChart(for input: NatalChartInput) throws -> NatalChart {
        let moment = try utcMoment(from: input)
        let year = try required(moment.year, label: "year")
        let month = try required(moment.month, label: "month")
        let day = try required(moment.day, label: "day")
        let hour = try required(moment.hour, label: "hour")
        let minute = try required(moment.minute, label: "minute")
        let second = try required(moment.second, label: "second")
        let observer = Astronomy_MakeObserver(
            input.latitude,
            input.longitude,
            input.altitudeMeters
        )

        var calculationTime = Astronomy_MakeTime(
            CInt(year),
            CInt(month),
            CInt(day),
            CInt(hour),
            CInt(minute),
            Double(second)
        )

        let sunLongitude = try sunLongitude(at: calculationTime)
        let moonLongitude = try moonLongitude(at: calculationTime)
        let ascendantLongitude = try ascendantLongitude(
            at: &calculationTime,
            observer: observer
        )

        return NatalChart(
            sun: ZodiacPlacement(longitude: sunLongitude),
            moon: ZodiacPlacement(longitude: moonLongitude),
            ascendant: ZodiacPlacement(longitude: ascendantLongitude)
        )
    }
}

private extension AstronomyEngine {
    static func utcMoment(from input: NatalChartInput) throws -> DateComponents {
        guard let timeZone = TimeZone(identifier: input.timeZoneIdentifier) else {
            throw AstronomyEngineError.invalidTimeZone(input.timeZoneIdentifier)
        }

        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = timeZone

        let localComponents = DateComponents(
            calendar: localCalendar,
            timeZone: timeZone,
            year: input.year,
            month: input.month,
            day: input.day,
            hour: input.hour,
            minute: input.minute,
            second: 0
        )

        guard let localDate = localCalendar.date(from: localComponents) else {
            throw AstronomyEngineError.invalidLocalDate
        }

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        let utcComponents = utcCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: localDate
        )

        guard
            utcComponents.year != nil,
            utcComponents.month != nil,
            utcComponents.day != nil,
            utcComponents.hour != nil,
            utcComponents.minute != nil,
            utcComponents.second != nil
        else {
            throw AstronomyEngineError.invalidUTCComponents
        }

        return utcComponents
    }

    static func sunLongitude(at time: astro_time_t) throws -> Double {
        let result = Astronomy_SunPosition(time)
        try assertSuccess(result.status, label: "sun")
        return normalize(result.elon)
    }

    static func moonLongitude(at time: astro_time_t) throws -> Double {
        let result = Astronomy_EclipticGeoMoon(time)
        try assertSuccess(result.status, label: "moon")
        return normalize(result.lon)
    }

    static func ascendantLongitude(
        at time: inout astro_time_t,
        observer: astro_observer_t
    ) throws -> Double {
        let eclipticNorthPole = makeVector(
            x: 0,
            y: 0,
            z: 1,
            time: time
        )
        let eclipticToHorizon = Astronomy_Rotation_ECL_HOR(&time, observer)
        let horizonPoleVector = Astronomy_RotateVector(
            eclipticToHorizon,
            eclipticNorthPole
        )
        try assertSuccess(horizonPoleVector.status, label: "ascendant.horizonPole")

        var horizonIntersection = makeVector(
            x: horizonPoleVector.y,
            y: -horizonPoleVector.x,
            z: 0,
            time: time
        )

        guard horizonIntersection.x != 0 || horizonIntersection.y != 0 else {
            throw AstronomyEngineError.invalidAscendantGeometry
        }

        if horizonIntersection.y > 0 {
            horizonIntersection.x *= -1
            horizonIntersection.y *= -1
        }

        let horizonToEcliptic = Astronomy_Rotation_HOR_ECL(&time, observer)
        let eclipticIntersection = Astronomy_RotateVector(
            horizonToEcliptic,
            horizonIntersection
        )
        try assertSuccess(eclipticIntersection.status, label: "ascendant.eclipticIntersection")

        let eclipticSphere = Astronomy_SphereFromVector(eclipticIntersection)
        try assertSuccess(eclipticSphere.status, label: "ascendant.eclipticSphere")

        return normalize(eclipticSphere.lon)
    }

    static func makeVector(
        x: Double,
        y: Double,
        z: Double,
        time: astro_time_t
    ) -> astro_vector_t {
        astro_vector_t(
            status: ASTRO_SUCCESS,
            x: x,
            y: y,
            z: z,
            t: time
        )
    }

    static func assertSuccess(
        _ status: astro_status_t,
        label: String
    ) throws {
        guard status == ASTRO_SUCCESS else {
            throw AstronomyEngineError.calculationFailed(
                label: label,
                statusCode: Int(status.rawValue)
            )
        }
    }

    static func normalize(_ longitude: Double) -> Double {
        let remainder = longitude.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }

    static func required(
        _ value: Int?,
        label: String
    ) throws -> Int {
        guard let value else {
            throw AstronomyEngineError.invalidUTCComponent(label)
        }

        return value
    }
}

private enum AstronomyEngineError: LocalizedError {
    case invalidTimeZone(String)
    case invalidLocalDate
    case invalidUTCComponents
    case invalidUTCComponent(String)
    case invalidAscendantGeometry
    case calculationFailed(label: String, statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidTimeZone(let identifier):
            "Unknown time zone identifier: \(identifier)"
        case .invalidLocalDate:
            "Unable to construct a local birth date from the provided input."
        case .invalidUTCComponents:
            "Unable to convert the local birth date into UTC components."
        case .invalidUTCComponent(let label):
            "The UTC conversion is missing the \(label) component."
        case .invalidAscendantGeometry:
            "Unable to determine the ascendant because the horizon/ecliptic intersection is degenerate."
        case .calculationFailed(let label, let statusCode):
            "Astronomy Engine failed while calculating \(label). Status code: \(statusCode)."
        }
    }
}
