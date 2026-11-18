import Testing
@testable import PerfumeSoulBackend

struct QuizBankTests {
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
