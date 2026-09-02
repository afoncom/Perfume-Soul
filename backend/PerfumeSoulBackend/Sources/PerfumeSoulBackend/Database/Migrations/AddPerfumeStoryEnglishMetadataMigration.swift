import Fluent
import FluentSQL

struct AddPerfumeStoryEnglishMetadataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("""
            ALTER TABLE perfumes
                ADD COLUMN IF NOT EXISTS short_description_en TEXT,
                ADD COLUMN IF NOT EXISTS recommendation_reason_en TEXT,
                ADD COLUMN IF NOT EXISTS full_story_en TEXT
            """)
            .run()
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("""
            ALTER TABLE perfumes
                DROP COLUMN IF EXISTS short_description_en,
                DROP COLUMN IF EXISTS recommendation_reason_en,
                DROP COLUMN IF EXISTS full_story_en
            """)
            .run()
    }
}
