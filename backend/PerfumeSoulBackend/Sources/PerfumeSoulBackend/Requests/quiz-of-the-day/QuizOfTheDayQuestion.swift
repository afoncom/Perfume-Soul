import Foundation
import Fluent

struct QuizOfTheDayQuestion: Codable, Equatable {
    let id: Int
    let question: String
    let answers: [Answer]
    let explanation: String

    struct Answer: Codable, Equatable {
        let id: String
        let text: String
        let isCorrect: Bool
    }
}

enum QuizOfTheDayQuestionLoader {
    static func load() throws -> [QuizOfTheDayQuestion] {
        guard let url = Bundle.module.url(forResource: "quiz-of-the-day", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode([QuizOfTheDayQuestion].self, from: Data(contentsOf: url))
    }

    static func load(on database: any Database, language: String?) async throws -> [QuizOfTheDayQuestion] {
        let questions = try await QuizBankQuestionModel.query(on: database)
            .sort(\.$id)
            .limit(15)
            .all()
        return questions.map { $0.payload.response(language: language) }
    }
}
