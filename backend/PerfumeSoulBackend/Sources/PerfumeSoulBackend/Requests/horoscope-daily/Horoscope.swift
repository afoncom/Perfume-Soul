import Fluent
import Vapor

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

struct DailyHoroscopeQuery: Content {
    let timeZone: String?
}

enum DailyHoroscopeLoader {
    static func load(
        dateKey: String,
        language: String?,
        on database: any Database
    ) async throws -> [DailyHoroscope]? {
        let horoscopes = try await DailyHoroscopeEntryModel.query(on: database)
            .filter(\.$dateKey == dateKey)
            .sort(\.$sortOrder)
            .all()

        guard !horoscopes.isEmpty else {
            return nil
        }
        try validate(horoscopes)

        let isRussian = language?.lowercased().hasPrefix("ru") == true
        return horoscopes.map { model in
            DailyHoroscope(
                sign: model.sign,
                energyOfDay: isRussian ? model.energyOfDayRu : model.energyOfDayEn
            )
        }
    }
}

extension DailyHoroscopeLoader {
    private static let expectedSigns: Set<String> = [
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

    private static func validate(_ horoscopes: [DailyHoroscopeEntryModel]) throws {
        guard horoscopes.count == expectedSigns.count else {
            throw Abort(
                .internalServerError,
                reason: "daily_horoscope_entries must contain exactly 12 signs for the date"
            )
        }

        let loadedSigns = Set(horoscopes.map(\.sign))
        guard loadedSigns == expectedSigns else {
            throw Abort(
                .internalServerError,
                reason: "daily_horoscope_entries contains an invalid or incomplete sign set"
            )
        }
    }
}
