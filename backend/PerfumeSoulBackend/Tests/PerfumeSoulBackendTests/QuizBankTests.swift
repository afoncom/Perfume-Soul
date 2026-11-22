import Foundation
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct QuizBankTests {
    @Test("The original endpoint preserves the fifteen legacy questions without querying the bank")
    func legacyEndpointPreservesQuestions() async throws {
        let database = CallbackTestDatabase { _ in
            Issue.record("The legacy endpoint must not query the new bank")
            return []
        }
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(.GET, "/quiz-of-the-day") { response in
                #expect(response.status == .ok)
                let questions = try JSONDecoder().decode(
                    [QuizOfTheDayQuestion].self, from: Data(response.body.string.utf8)
                )
                #expect(questions.map(\.id) == Array(1...15))
                #expect(questions.first?.question == "Какие ноты чаще всего относятся к верхним (начальным) нотам аромата?")
                #expect(questions.first?.answers.first { $0.isCorrect }?.id == "B")
            }
        }
    }

    @Test("The versioned endpoint returns the new bank in the requested language", arguments: ["ru", "en"])
    func versionedEndpointUsesBank(language: String) async throws {
        let database = ArrayTestDatabase()
        let models = try QuizBankSeed.load().prefix(15).map { entry in
            let model = QuizBankQuestionModel()
            model.id = entry.id
            model.payload = entry
            return model
        }
        database.append(models)
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(
                .GET, "/v2/quiz-of-the-day", headers: ["Accept-Language": language]
            ) { response in
                #expect(response.status == .ok)
                let questions = try JSONDecoder().decode(
                    [QuizOfTheDayQuestion].self, from: Data(response.body.string.utf8)
                )
                #expect(questions.map(\.id) == Array(10_001...10_015))
                let expected = language == "en"
                    ? "Which part of bergamot yields its essential oil?"
                    : "Из какой части бергамота получают эфирное масло?"
                #expect(questions.first?.question == expected)
            }
        }
    }

    @Test("The packaged bank contains all new questions")
    func packagedBankIsComplete() throws {
        let entries = try QuizBankSeed.load()
        #expect(entries.count == 5475)
        #expect(entries.map(\.id) == Array(10_001...15_475))
    }

    @Test("The first new question is localized without changing the API contract")
    func localizesQuestion() throws {
        let entry = try #require(QuizBankSeed.load().first)
        let russian = entry.response(language: "ru")
        let english = entry.response(language: "en-US")

        #expect(russian.id == 10_001)
        #expect(russian.question == "Из какой части бергамота получают эфирное масло?")
        #expect(english.question == "Which part of bergamot yields its essential oil?")
        #expect(russian.answers.count == 4)
        #expect(russian.answers.filter(\.isCorrect).count == 1)
        #expect(english.answers.filter(\.isCorrect).count == 1)
    }
}
