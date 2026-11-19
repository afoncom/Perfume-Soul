import Fluent
import FluentSQL
import Foundation

struct CreateDailyHoroscopeEntriesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let monthlyJSON = try DailyHoroscopeSeed.validatedMonthlyJSON()
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await database.schema(DailyHoroscopeEntryModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("date_key", .string, .required)
            .field("sign", .string, .required)
            .field("energy_of_day_ru", .string, .required)
            .field("energy_of_day_en", .string, .required)
            .field("sort_order", .int, .required)
            .unique(on: "date_key", "sign")
            .ignoreExisting()
            .create()

        for data in monthlyJSON {
            let json = String(decoding: data, as: UTF8.self)
            let query = sqlDatabase.raw("""
                INSERT INTO daily_horoscope_entries
                    (date_key, sign, energy_of_day_ru, energy_of_day_en, sort_order)
                SELECT
                    day.value ->> 'date',
                    forecast.key,
                    forecast.value ->> 'ru',
                    forecast.value ->> 'en',
                    CASE forecast.key
                        WHEN 'aries' THEN 1 WHEN 'taurus' THEN 2
                        WHEN 'gemini' THEN 3 WHEN 'cancer' THEN 4
                        WHEN 'leo' THEN 5 WHEN 'virgo' THEN 6
                        WHEN 'libra' THEN 7 WHEN 'scorpio' THEN 8
                        WHEN 'sagittarius' THEN 9 WHEN 'capricorn' THEN 10
                        WHEN 'aquarius' THEN 11 WHEN 'pisces' THEN 12
                    END
                FROM jsonb_array_elements((\(bind: json)::jsonb) -> 'days') AS day(value)
                CROSS JOIN LATERAL jsonb_each(day.value -> 'signs') AS forecast(key, value)
                WHERE true
                ON CONFLICT (date_key, sign) DO UPDATE SET
                    energy_of_day_ru = EXCLUDED.energy_of_day_ru,
                    energy_of_day_en = EXCLUDED.energy_of_day_en,
                    sort_order = EXCLUDED.sort_order
                """)
            try await query.run()
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(DailyHoroscopeEntryModel.schema).delete()
    }
}
