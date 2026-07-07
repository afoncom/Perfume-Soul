import Fluent
import FluentSQL

struct AddPerfumeProfileMetadataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("""
            ALTER TABLE perfumes
                ADD COLUMN IF NOT EXISTS concentration TEXT,
                ADD COLUMN IF NOT EXISTS fragrance_family TEXT,
                ADD COLUMN IF NOT EXISTS season_profile TEXT,
                ADD COLUMN IF NOT EXISTS occasion_profile TEXT,
                ADD COLUMN IF NOT EXISTS style_profile TEXT,
                ADD COLUMN IF NOT EXISTS gender_profile TEXT,
                ADD COLUMN IF NOT EXISTS mood_profile TEXT
            """).run()
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("""
            ALTER TABLE perfumes
                DROP COLUMN IF EXISTS concentration,
                DROP COLUMN IF EXISTS fragrance_family,
                DROP COLUMN IF EXISTS season_profile,
                DROP COLUMN IF EXISTS occasion_profile,
                DROP COLUMN IF EXISTS style_profile,
                DROP COLUMN IF EXISTS gender_profile,
                DROP COLUMN IF EXISTS mood_profile
            """).run()
    }
}
