import Fluent
import FluentSQL

struct AddPerfumeScoreColumnsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("""
            ALTER TABLE perfumes
                ADD COLUMN IF NOT EXISTS longevity_score INTEGER,
                ADD COLUMN IF NOT EXISTS sillage_score INTEGER
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
                DROP COLUMN IF EXISTS longevity_score,
                DROP COLUMN IF EXISTS sillage_score
            """)
            .run()
    }
}
