import Foundation

struct QuizBankEntry: Codable, Sendable {
    struct LocalizedText: Codable, Sendable {
        let ru: String
        let en: String

        func value(for language: String?) -> String {
            language?.lowercased().hasPrefix("en") == true ? en : ru
        }
    }

    struct Answer: Codable, Sendable {
        let id: String
        let ru: String
        let en: String

        func value(for language: String?) -> String {
            language?.lowercased().hasPrefix("en") == true ? en : ru
        }
    }

    struct Source: Codable, Sendable {
        let url: String
        let locator: String
    }

    let id: Int
    let topic: String
    let conceptKey: String
    let difficulty: String
    let question: LocalizedText
    let answers: [Answer]
    let correctAnswerId: String
    let explanation: LocalizedText
    let sources: [Source]

    func response(language: String?) -> QuizOfTheDayQuestion {
        QuizOfTheDayQuestion(
            id: id,
            question: question.value(for: language),
            answers: answers.map { answer in
                QuizOfTheDayQuestion.Answer(
                    id: answer.id,
                    text: answer.value(for: language),
                    isCorrect: answer.id == correctAnswerId
                )
            },
            explanation: explanation.value(for: language)
        )
    }
}

enum QuizBankSeed {
    private struct Bank: Decodable {
        let schemaVersion: Int
        let questions: [QuizBankEntry]
    }

    static func load() throws -> [QuizBankEntry] {
        guard let url = Bundle.module.url(forResource: "quiz-bank", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }

        let bank = try JSONDecoder().decode(Bank.self, from: Data(contentsOf: url))
        guard bank.schemaVersion == 1 else {
            throw QuizBankSeedError.invalidBank
        }
        guard bank.questions.count == 5475,
            bank.questions.map(\.id) == Array(10_001...15_475) else {
            throw QuizBankSeedError.invalidBank
        }
        return bank.questions
    }
}

private enum QuizBankSeedError: Error {
    case invalidBank
}
