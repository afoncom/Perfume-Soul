import Fluent
import FluentSQL
import Foundation

struct CreateLegacyPerfumeryHistoryMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let url = Bundle.module.url(forResource: "perfumery-history-legacy", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let item = try JSONDecoder().decode(LegacyPerfumeryHistoryItem.self, from: Data(contentsOf: url))

        try await database.transaction { database in
            try await database.schema(LegacyPerfumeryHistoryModel.schema)
                .field(.id, .int, .identifier(auto: true))
                .field("date_key", .string, .required)
                .field("year", .int, .required)
                .field("perfume_name", .string, .required)
                .field("short_story", .string, .required)
                .field("full_story", .string, .required)
                .field("image_url", .string, .required)
                .unique(on: "date_key")
                .ignoreExisting()
                .create()

            guard let sqlDatabase = database as? any SQLDatabase else {
                throw DatabaseMigrationError.sqlDatabaseIsRequired
            }
            let query = sqlDatabase.raw("""
                INSERT INTO perfumery_history
                    (date_key, year, perfume_name, short_story, full_story, image_url)
                VALUES (
                    \(bind: "2026-04-18"), \(bind: item.year), \(bind: item.perfumeName),
                    \(bind: item.shortStory), \(bind: item.fullStory), \(bind: item.imageUrl)
                )
                ON CONFLICT (date_key) DO NOTHING
                """)
            try await query.run()
        }
    }

    func revert(on _: any Database) async throws {
        // The legacy table may predate Fluent migrations; preserve its existing data on rollback.
    }
}
