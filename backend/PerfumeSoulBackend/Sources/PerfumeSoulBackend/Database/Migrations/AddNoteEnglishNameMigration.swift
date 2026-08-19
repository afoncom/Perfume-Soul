import Fluent
import FluentSQL

struct AddNoteEnglishNameMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("ALTER TABLE notes ADD COLUMN IF NOT EXISTS name_en TEXT")
            .run()
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("ALTER TABLE notes DROP COLUMN IF EXISTS name_en")
            .run()
    }
}
