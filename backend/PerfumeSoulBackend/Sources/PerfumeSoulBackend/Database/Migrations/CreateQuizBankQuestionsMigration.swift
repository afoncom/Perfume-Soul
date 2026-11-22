import Fluent
import FluentSQL
import Foundation

struct CreateQuizBankQuestionsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let entries = try QuizBankSeed.load()

        try await database.transaction { database in
            try await database.schema(QuizBankQuestionModel.schema)
                .field(.id, .int, .identifier(auto: false))
                .field("payload", .json, .required)
                .ignoreExisting()
                .create()

            guard let sqlDatabase = database as? any SQLDatabase else {
                throw DatabaseMigrationError.sqlDatabaseIsRequired
            }

            for start in stride(from: 0, to: entries.count, by: 200) {
                let batch = Array(entries[start..<min(start + 200, entries.count)])
                let json = String(decoding: try JSONEncoder().encode(batch), as: UTF8.self)
                try await sqlDatabase.raw("""
                    INSERT INTO quiz_bank_questions (id, payload)
                    SELECT (value ->> 'id')::integer, value
                    FROM jsonb_array_elements(\(bind: json)::jsonb) AS item(value)
                    WHERE true
                    ON CONFLICT (id) DO UPDATE SET payload = EXCLUDED.payload
                    """)
                    .run()
            }
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(QuizBankQuestionModel.schema).delete()
    }
}
