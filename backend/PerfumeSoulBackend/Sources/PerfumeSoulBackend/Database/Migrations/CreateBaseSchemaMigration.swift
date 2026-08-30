import Fluent
import FluentSQL

struct CreateBaseSchemaMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("""
            DO $$
            BEGIN
                CREATE TYPE perfume_note_type AS ENUM ('top', 'middle', 'base');
            EXCEPTION
                WHEN duplicate_object THEN NULL;
            END
            $$;
            """).run()

        let perfumeNoteType = try await database.enum("perfume_note_type").read()

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
            .field("note_type", perfumeNoteType, .required)
            .field("sort_order", .int, .required)
            .foreignKey("perfume_id", references: PerfumeModel.schema, .id, onDelete: .cascade)
            .foreignKey("note_id", references: NoteModel.schema, .id, onDelete: .cascade)
            .ignoreExisting()
            .create()

        try await sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_perfume_notes_perfume_note_type
            ON perfume_notes (perfume_id, note_id, note_type)
            """).run()

        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_perfume_notes_perfume_id
            ON perfume_notes (perfume_id)
            """).run()
    }

    func revert(on _: any Database) async throws {
        // This baseline migration also runs against imported databases where these tables already exist.
        // Reverting it must not drop user catalog data.
    }
}
