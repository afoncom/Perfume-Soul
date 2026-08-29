import Fluent

struct CreateBaseSchemaMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(BrandModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("brand", .string, .required)
            .ignoreExisting()
            .create()

        try await database.schema(PerfumeModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("perfume_name", .string, .required)
            .field("brand_id", .int, .required)
            .foreignKey("brand_id", references: BrandModel.schema, .id, onDelete: .cascade)
            .ignoreExisting()
            .create()

        try await database.schema(NoteModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .ignoreExisting()
            .create()

        try await database.schema(PerfumeNoteModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("perfume_id", .int, .required)
            .field("note_id", .int, .required)
            .field("note_type", .string, .required)
            .field("sort_order", .int, .required)
            .foreignKey("perfume_id", references: PerfumeModel.schema, .id, onDelete: .cascade)
            .foreignKey("note_id", references: NoteModel.schema, .id, onDelete: .cascade)
            .ignoreExisting()
            .create()
    }

    func revert(on _: any Database) async throws {
        // This baseline migration also runs against imported databases where these tables already exist.
        // Reverting it must not drop user catalog data.
    }
}
