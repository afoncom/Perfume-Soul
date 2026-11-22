import Foundation
import Fluent
import FluentPostgresDriver
import FluentSQL
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct QuizCalendarTests {
    @Test("Replaying calendar migration preserves already published assignments", .enabled(
        if: Environment.get("PERFUME_SOUL_TEST_DATABASE_URL") != nil
    ))
    func migrationPreservesPublishedDates() async throws {
        let databaseURL = try #require(Environment.get("PERFUME_SOUL_TEST_DATABASE_URL"))
        let days = try QuizCalendar.load()
        let first = try #require(days.first)
        try await withApp { app in
            app.databases.use(try .postgres(url: databaseURL), as: .psql)
            let migration = CreateQuizCalendarDaysMigration()
            try await migration.prepare(on: app.db)
            let storedDays = try await QuizCalendarDayModel.query(on: app.db).all()
            let expected = Dictionary(uniqueKeysWithValues: days.map { ($0.dayKey, $0.questionIDs) })
            #expect(storedDays.count == days.count)
            for storedDay in storedDays {
                let dayKey = try #require(storedDay.id)
                #expect(storedDay.questionIDs == expected[dayKey])
            }
            let published = try #require(try await QuizCalendarDayModel.find(first.dayKey, on: app.db))
            let existingOrder = Array(first.questionIDs.reversed())
            published.questionIDs = existingOrder
            try await published.save(on: app.db)

            // Reproduce a database where the earlier JSON migration was already logged.
            let sqlDatabase = try #require(app.db as? any SQLDatabase)
            try await sqlDatabase.raw("""
                ALTER TABLE quiz_calendar_days
                ALTER COLUMN question_ids TYPE jsonb USING to_jsonb(question_ids)
                """)
                .run()
            try await UseNativeQuizQuestionIDsMigration().prepare(on: app.db)
            try await migration.prepare(on: app.db)
            let restored = try #require(try await QuizCalendarDayModel.find(first.dayKey, on: app.db))
            #expect(restored.questionIDs == existingOrder)
            #expect(try await QuizCalendarDayModel.query(on: app.db).count() == days.count)
            published.questionIDs = first.questionIDs
            try await published.save(on: app.db)
        }
    }

    @Test("Two complete daily calendars cover the bank once per cycle with balanced topics and difficulty")
    func completeCalendar() throws {
        let days = try QuizCalendar.load()
        let bank = try QuizBankSeed.load()
        let byID = Dictionary(uniqueKeysWithValues: bank.map { ($0.id, $0) })
        let calendar = Calendar(identifier: .gregorian)
        let formatter = ISO8601DateFormatter()
        let start = try #require(formatter.date(from: "2026-12-01T12:00:00Z"))
        #expect(days.count == 730)
        for (offset, day) in days.enumerated() {
            let date = try #require(calendar.date(byAdding: .day, value: offset, to: start))
            #expect(day.dayKey == String(formatter.string(from: date).prefix(10)))
            #expect(day.questionIDs.count == 15)
            #expect(Set(day.questionIDs).count == 15)
            let entries = try day.questionIDs.map { try #require(byID[$0]) }
            let topics = Dictionary(grouping: entries, by: \.topic)
            #expect(topics.count >= 5)
            #expect(topics.values.allSatisfy { $0.count <= 3 })
            #expect((9...10).contains(entries.filter { $0.difficulty == "easy" }.count))
            #expect((4...5).contains(entries.filter { $0.difficulty == "medium" }.count))
            #expect(entries.filter { $0.difficulty == "hard" }.count <= 1)
            #expect(entries.prefix(12).allSatisfy { $0.difficulty != "hard" })
            #expect(zip(entries, entries.dropFirst()).allSatisfy { $0.topic != $1.topic })
            #expect(entries.map { $0.response(language: "ru").id } == entries.map { $0.response(language: "en").id })
        }
        for start in [0, 365] {
            let ids = days[start..<start + 365].flatMap(\.questionIDs)
            #expect(ids.count == bank.count)
            #expect(Set(ids) == Set(bank.map(\.id)))
        }
        let lastMonth = Set(days[335..<365].flatMap(\.questionIDs))
        #expect(lastMonth.isDisjoint(with: days[365..<395].flatMap(\.questionIDs)))
    }

    @Test("The daily endpoint restores calendar order independently of database order and language", arguments: ["ru", "en"])
    func dailyEndpoint(language: String) async throws {
        let day = try #require(QuizCalendar.load().first)
        let bank = try QuizBankSeed.load()
        let byID = Dictionary(uniqueKeysWithValues: bank.map { ($0.id, $0) })
        let database = ArrayTestDatabase()
        let model = QuizCalendarDayModel()
        model.id = day.dayKey
        model.questionIDs = day.questionIDs
        database.append([model])
        let questions = try day.questionIDs.reversed().map { id in
            let question = QuizBankQuestionModel()
            question.id = id
            question.payload = try #require(byID[id])
            return question
        }
        database.append(questions)
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(
                .GET, "/v2/quiz-of-the-day?dayKey=\(day.dayKey)", headers: ["Accept-Language": language]
            ) { response in
                #expect(response.status == .ok)
                let returned = try JSONDecoder().decode(
                    [QuizOfTheDayQuestion].self, from: Data(response.body.string.utf8)
                )
                #expect(returned.map(\.id) == day.questionIDs)
                #expect(returned == day.questionIDs.compactMap { byID[$0]?.response(language: language) })
            }
        }
    }

    @Test("Malformed dates are rejected", arguments: ["2026-02-30", "2026-2-01", "not-a-date", ""])
    func invalidDate(value: String) async throws {
        let database = CallbackTestDatabase { _ in
            Issue.record("Malformed dates must not query the database")
            return []
        }
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(.GET, "/v2/quiz-of-the-day?dayKey=\(value)") { response in
                #expect(response.status == .badRequest)
            }
        }
    }

    @Test("An unpublished day returns 404 instead of a different day's questions")
    func missingDay() async throws {
        let database = CallbackTestDatabase { _ in [] }
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(.GET, "/v2/quiz-of-the-day?dayKey=2026-11-30") { response in
                #expect(response.status == .notFound)
            }
        }
    }
}
