import Fluent
import Vapor

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load(on database: any Database) async throws -> [DailyHoroscope] {
        let horoscopes = try await DailyHoroscopeModel.query(on: database)
            .sort(\.$sortOrder)
            .all()

        try validate(horoscopes)

        return horoscopes.map(DailyHoroscope.init(model:))
    }
}

private extension DailyHoroscopeLoader {
    static let expectedSigns: Set<String> = [
        "aries",
        "taurus",
        "gemini",
        "cancer",
        "leo",
        "virgo",
        "libra",
        "scorpio",
        "sagittarius",
        "capricorn",
        "aquarius",
        "pisces"
    ]

    static func validate(_ horoscopes: [DailyHoroscopeModel]) throws {
        guard horoscopes.count == expectedSigns.count else {
            throw Abort(
                .internalServerError,
                reason: "daily_horoscopes must contain exactly 12 signs"
            )
        }

        let loadedSigns = Set(horoscopes.map(\.sign))
        guard loadedSigns == expectedSigns else {
            throw Abort(
                .internalServerError,
                reason: "daily_horoscopes contains an invalid or incomplete sign set"
            )
        }
    }
}

private extension DailyHoroscope {
    init(model: DailyHoroscopeModel) {
        self.sign = model.sign
        self.energyOfDay = model.energyOfDay
    }
}
