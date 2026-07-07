import Fluent
import FluentSQL

struct CreatePerfumeAccordsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(AccordModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .unique(on: "name")
            .ignoreExisting()
            .create()

        try await database.schema(PerfumeAccordModel.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("perfume_id", .int, .required)
            .field("accord_id", .int, .required)
            .field("weight", .double, .required)
            .foreignKey("perfume_id", references: PerfumeModel.schema, .id, onDelete: .cascade)
            .foreignKey("accord_id", references: AccordModel.schema, .id, onDelete: .cascade)
            .unique(on: "perfume_id", "accord_id")
            .ignoreExisting()
            .create()

        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_perfume_accords_perfume_id
            ON perfume_accords (perfume_id)
            """).run()
        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_perfume_accords_accord_id
            ON perfume_accords (accord_id)
            """).run()
        try await sqlDatabase.raw("""
            CREATE INDEX IF NOT EXISTS idx_perfume_accords_perfume_weight
            ON perfume_accords (perfume_id, weight DESC)
            """).run()
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase.raw("DROP TABLE IF EXISTS perfume_accords").run()
        try await sqlDatabase.raw("DROP TABLE IF EXISTS accords").run()
    }
}
