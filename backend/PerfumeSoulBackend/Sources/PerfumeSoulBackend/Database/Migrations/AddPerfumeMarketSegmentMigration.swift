import Fluent
import FluentSQL

struct AddPerfumeMarketSegmentMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("""
            ALTER TABLE perfumes
                ADD COLUMN IF NOT EXISTS market_segment TEXT
            """)
            .run()

        try await sqlDatabase
            .raw("""
            UPDATE perfumes
            SET market_segment = CASE
                WHEN brands.brand IN (
                    'Byredo',
                    'Diptyque',
                    'Kilian Paris',
                    'Le Labo',
                    'Maison Margiela',
                    'Initio'
                ) THEN 'niche'
                WHEN brands.brand IN (
                    'Creed',
                    'Maison Francis Kurkdjian',
                    'Parfums de Marly',
                    'Tom Ford'
                ) THEN 'luxury'
                WHEN brands.brand IN (
                    'Burberry',
                    'Chanel',
                    'Dior',
                    'Giorgio Armani',
                    'Narciso Rodriguez'
                ) THEN 'daily'
                ELSE 'unclassified'
            END
            FROM brands
            WHERE perfumes.brand_id = brands.id AND perfumes.market_segment IS NULL
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
                DROP COLUMN IF EXISTS market_segment
            """)
            .run()
    }
}
