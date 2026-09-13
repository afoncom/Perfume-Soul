import Fluent
import FluentSQL

struct AddCatalogImportSupportMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_brands_normalized_name
            ON brands ((lower(btrim(brand))))
            """).run()
        try await sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_perfumes_normalized_brand_name
            ON perfumes (brand_id, (lower(btrim(perfume_name))))
            """).run()
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }
        try await sqlDatabase.raw("DROP INDEX IF EXISTS idx_perfumes_name_trigram").run()
        try await sqlDatabase.raw("DROP INDEX IF EXISTS idx_brands_name_trigram").run()
        try await sqlDatabase.raw("DROP INDEX IF EXISTS idx_perfumes_normalized_brand_name").run()
        try await sqlDatabase.raw("DROP INDEX IF EXISTS idx_brands_normalized_name").run()
    }
}
