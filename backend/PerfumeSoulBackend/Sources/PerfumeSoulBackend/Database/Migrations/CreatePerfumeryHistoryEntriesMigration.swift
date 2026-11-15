import Fluent

struct CreatePerfumeryHistoryEntriesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let entries = try PerfumeryHistorySeed.entries()
        try await database.schema(PerfumeryHistoryModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("date_key", .string, .required)
            .field("event_year", .int, .required)
            .field("title_ru", .string, .required)
            .field("title_en", .string, .required)
            .field("full_story_ru", .string, .required)
            .field("full_story_en", .string, .required)
            .unique(on: "date_key")
            .create()

        for entry in entries {
            try await PerfumeryHistoryModel(entry: entry).create(on: database)
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PerfumeryHistoryModel.schema).delete()
    }
}
