import Fluent

struct CreateUnfoundSearchQueriesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UnfoundSearchQueryModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("query_text", .string, .required)
            .field("normalized_query", .string, .required)
            .field("search_context", .string, .required)
            .field("occurrence_count", .int, .required)
            .field("first_seen_at", .datetime)
            .field("last_seen_at", .datetime)
            .unique(on: "normalized_query", "search_context")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UnfoundSearchQueryModel.schema).delete()
    }
}
