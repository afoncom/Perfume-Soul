import Fluent
import FluentSQL

struct CreatePerfumeryHistoryEntriesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let entries = try PerfumeryHistorySeed.entries()
        try await database.transaction { database in
            try await database.schema(PerfumeryHistoryModel.schema)
                .field(.id, .int, .identifier(auto: true))
                .field("date_key", .string, .required)
                .field("event_year", .int, .required)
                .field("title_ru", .string, .required)
                .field("title_en", .string, .required)
                .field("full_story_ru", .string, .required)
                .field("full_story_en", .string, .required)
                .unique(on: "date_key")
                .ignoreExisting()
                .create()

            guard let sqlDatabase = database as? any SQLDatabase else {
                throw DatabaseMigrationError.sqlDatabaseIsRequired
            }
            for entry in entries {
                try await sqlDatabase.raw("""
                    INSERT INTO perfumery_history_entries
                        (date_key, event_year, title_ru, title_en, full_story_ru, full_story_en)
                    VALUES
                        (\(bind: entry.dateKey), \(bind: entry.eventYear), \(bind: entry.titleRu),
                         \(bind: entry.titleEn), \(bind: entry.fullStoryRu), \(bind: entry.fullStoryEn))
                    ON CONFLICT (date_key) DO UPDATE SET
                        event_year = EXCLUDED.event_year,
                        title_ru = EXCLUDED.title_ru,
                        title_en = EXCLUDED.title_en,
                        full_story_ru = EXCLUDED.full_story_ru,
                        full_story_en = EXCLUDED.full_story_en
                    """).run()
            }
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PerfumeryHistoryModel.schema).delete()
    }
}
