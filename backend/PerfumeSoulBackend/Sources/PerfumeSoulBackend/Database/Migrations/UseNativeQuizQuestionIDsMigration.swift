import Fluent
import FluentSQL

struct UseNativeQuizQuestionIDsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }
        try await sqlDatabase.raw("""
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_schema = current_schema()
                        AND table_name = 'quiz_calendar_days'
                        AND column_name = 'question_ids'
                        AND data_type IN ('json', 'jsonb')
                ) THEN
                    ALTER TABLE quiz_calendar_days
                    ALTER COLUMN question_ids TYPE bigint[]
                    USING translate(question_ids::text, '[]', '{}')::bigint[];
                END IF;
            END $$;
            """)
            .run()
    }

    func revert(on database: any Database) async throws {
        // Keep the compatible array representation; the create migration owns the table.
    }
}
