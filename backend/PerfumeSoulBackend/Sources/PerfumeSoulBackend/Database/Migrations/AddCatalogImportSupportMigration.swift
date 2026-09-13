import Fluent
import FluentSQL

struct AddCatalogImportSupportMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("CREATE EXTENSION IF NOT EXISTS pg_trgm").run()
        try await sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_brands_normalized_name
            ON brands ((lower(btrim(brand))))
            """).run()
        try await sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_perfumes_normalized_brand_name
            ON perfumes (brand_id, (lower(btrim(perfume_name))))
            """).run()
        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_perfumes_name_trigram
            ON perfumes USING GIN (perfume_name gin_trgm_ops)
            """).run()
        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_brands_name_trigram
            ON brands USING GIN (brand gin_trgm_ops)
            """).run()
    }

    func revert(on _: any Database) async throws {
        // Catalogue data and indexes are intentionally retained on rollback.
    }
}
