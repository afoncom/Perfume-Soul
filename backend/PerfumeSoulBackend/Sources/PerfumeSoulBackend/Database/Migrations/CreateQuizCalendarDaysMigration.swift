import Fluent
import FluentSQL
import Foundation

struct CreateQuizCalendarDaysMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let days = try QuizCalendar.load()
        try await database.transaction { database in
            try await database.schema(QuizCalendarDayModel.schema)
                .field("day_key", .string, .identifier(auto: false))
                .field("question_ids", .json, .required)
                .ignoreExisting()
                .create()
            guard let sqlDatabase = database as? any SQLDatabase else {
                throw DatabaseMigrationError.sqlDatabaseIsRequired
            }
            for start in stride(from: 0, to: days.count, by: 100) {
                let batch = Array(days[start..<min(start + 100, days.count)])
                let json = String(decoding: try JSONEncoder().encode(batch), as: UTF8.self)
                // Keep published dates unchanged, including after a replay of prepare.
                try await sqlDatabase.raw("""
                    INSERT INTO quiz_calendar_days (day_key, question_ids)
                    SELECT value ->> 'dayKey', value -> 'questionIDs'
                    FROM jsonb_array_elements(\(bind: json)::jsonb) AS item(value)
                    WHERE true
                    ON CONFLICT (day_key) DO NOTHING
                    """)
                    .run()
            }
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(QuizCalendarDayModel.schema).delete()
    }
}
