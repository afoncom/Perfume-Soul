import Fluent
import FluentSQL
import Foundation

struct CreateLegacyDailyHoroscopesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let url = Bundle.module.url(forResource: "daily-horoscopes-legacy", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let horoscopes = try JSONDecoder().decode([DailyHoroscope].self, from: Data(contentsOf: url))

        try await database.transaction { database in
            try await database.schema(DailyHoroscopeModel.schema)
                .field(.id, .int, .identifier(auto: true))
                .field("sign", .string, .required)
                .field("energy_of_day", .string, .required)
                .field("sort_order", .int, .required)
                .unique(on: "sign")
                .unique(on: "sort_order")
                .ignoreExisting()
                .create()

            guard let sqlDatabase = database as? any SQLDatabase else {
                throw DatabaseMigrationError.sqlDatabaseIsRequired
            }
            for (index, horoscope) in horoscopes.enumerated() {
                let query = sqlDatabase.raw("""
                    INSERT INTO daily_horoscopes (sign, energy_of_day, sort_order)
                    VALUES (\(bind: horoscope.sign), \(bind: horoscope.energyOfDay), \(bind: index + 1))
                    ON CONFLICT (sign) DO NOTHING
                    """)
                try await query.run()
            }
        }
    }

    func revert(on _: any Database) async throws {
        // The legacy table may predate Fluent migrations; preserve its existing data on rollback.
    }
}
