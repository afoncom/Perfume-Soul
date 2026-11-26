import Fluent
import FluentSQL
import Foundation

struct RefreshSecondQuizCycleMigration: AsyncMigration {
    private let todayKey: String

    init(todayKey: String = String(ISO8601DateFormatter().string(from: Date()).prefix(10))) {
        self.todayKey = todayKey
    }

    func prepare(on database: any Database) async throws {
        guard todayKey < "2027-12-01" else {
            return
        }
        let days = try QuizCalendar.load().filter { $0.dayKey >= "2027-12-01" }
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }
        for start in stride(from: 0, to: days.count, by: 100) {
            let batch = Array(days[start..<min(start + 100, days.count)])
            let json = String(decoding: try JSONEncoder().encode(batch), as: UTF8.self)
            try await sqlDatabase.raw("""
                UPDATE quiz_calendar_days AS day
                SET question_ids = ARRAY(
                    SELECT question_id::bigint
                    FROM jsonb_array_elements_text(item.value -> 'questionIDs') WITH ORDINALITY
                        AS question(question_id, position)
                    ORDER BY position
                )
                FROM jsonb_array_elements(\(bind: json)::jsonb) AS item(value)
                WHERE day.day_key = item.value ->> 'dayKey'
                    AND day.day_key >= '2027-12-01' AND day.day_key < '2028-11-30'
                """)
                .run()
        }
    }

    func revert(on database: any Database) async throws {
        // Never restore an older schedule after dates have been assigned to users.
    }
}
