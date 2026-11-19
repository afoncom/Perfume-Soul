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
    static func load(on database: any Database) async throws -> [DailyHoroscope] {
        let horoscopes = try await DailyHoroscopeModel.query(on: database)
            .sort(\.$sortOrder)
            .all()
        try validate(horoscopes.map(\.sign), schema: DailyHoroscopeModel.schema)
        return horoscopes.map { DailyHoroscope(sign: $0.sign, energyOfDay: $0.energyOfDay) }
    }

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
        try validate(horoscopes.map(\.sign), schema: DailyHoroscopeEntryModel.schema)

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

    private static func validate(_ signs: [String], schema: String) throws {
        guard signs.count == expectedSigns.count else {
            throw Abort(
                .internalServerError,
                reason: "\(schema) must contain exactly 12 signs"
            )
        }

        let loadedSigns = Set(signs)
        guard loadedSigns == expectedSigns else {
            throw Abort(
                .internalServerError,
                reason: "\(schema) contains an invalid or incomplete sign set"
            )
        }
    }
}
