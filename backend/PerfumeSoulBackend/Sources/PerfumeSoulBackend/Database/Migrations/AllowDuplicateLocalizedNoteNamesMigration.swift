import Fluent
import FluentSQL

struct AllowDuplicateLocalizedNoteNamesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        // Localized display names are not identifiers: different catalog notes can share a translation.
        try await sqlDatabase.raw("""
            ALTER TABLE notes
            DROP CONSTRAINT IF EXISTS notes_name_key
            """).run()
    }

    func revert(on _: any Database) async throws {
        // The uniqueness constraint cannot be restored after valid localized synonyms are stored.
    }
}
