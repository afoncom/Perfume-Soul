import Foundation

struct NatalChartInput: Equatable {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
    let altitudeMeters: Double

    init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String,
        altitudeMeters: Double = 0
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.altitudeMeters = altitudeMeters
    }
}

struct NatalChart: Equatable, Codable {
    let sun: ZodiacPlacement
    let moon: ZodiacPlacement
    let ascendant: ZodiacPlacement
}

struct ZodiacPlacement: Equatable, Codable {
    let sign: ZodiacSign
    let longitude: Double

    init(longitude: Double) {
        self.longitude = Self.normalize(longitude)
        self.sign = ZodiacSign(longitude: longitude)
    }

    private static func normalize(_ longitude: Double) -> Double {
        let remainder = longitude.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }
}
