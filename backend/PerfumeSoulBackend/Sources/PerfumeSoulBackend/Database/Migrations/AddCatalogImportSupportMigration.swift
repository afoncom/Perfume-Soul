import Fluent
import FluentSQL

struct AddCatalogImportSupportMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        let duplicateCheck = sqlDatabase.raw("""
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM brands GROUP BY lower(btrim(brand)) HAVING count(*) > 1
                ) THEN
                    RAISE EXCEPTION 'Cannot create catalog indexes: normalized brand duplicates exist.';
                END IF;
                IF EXISTS (
                    SELECT 1 FROM perfumes
                    GROUP BY brand_id, lower(btrim(perfume_name)) HAVING count(*) > 1
                ) THEN
                    RAISE EXCEPTION 'Cannot create catalog indexes: normalized perfume duplicates exist.';
                END IF;
            END $$;
            """)
        try await duplicateCheck.run()
        let brandIndex = sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_brands_normalized_name
            ON brands ((lower(btrim(brand))))
            """)
        try await brandIndex.run()
        let perfumeIndex = sqlDatabase.raw("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_perfumes_normalized_brand_name
            ON perfumes (brand_id, (lower(btrim(perfume_name))))
            """)
        try await perfumeIndex.run()
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
