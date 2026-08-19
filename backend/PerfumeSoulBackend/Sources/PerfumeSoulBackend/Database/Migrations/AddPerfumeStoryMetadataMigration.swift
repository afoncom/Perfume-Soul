import Fluent
import FluentSQL

struct AddPerfumeStoryMetadataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("""
            ALTER TABLE perfumes
                ADD COLUMN IF NOT EXISTS release_year INTEGER,
                ADD COLUMN IF NOT EXISTS perfumer TEXT,
                ADD COLUMN IF NOT EXISTS short_description TEXT,
                ADD COLUMN IF NOT EXISTS recommendation_reason TEXT,
                ADD COLUMN IF NOT EXISTS full_story TEXT
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
                DROP COLUMN IF EXISTS release_year,
                DROP COLUMN IF EXISTS perfumer,
                DROP COLUMN IF EXISTS short_description,
                DROP COLUMN IF EXISTS recommendation_reason,
                DROP COLUMN IF EXISTS full_story
            """)
            .run()
    }
}
