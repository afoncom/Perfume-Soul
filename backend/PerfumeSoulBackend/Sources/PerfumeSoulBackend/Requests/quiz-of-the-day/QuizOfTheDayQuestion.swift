import Foundation
import Fluent
import Vapor

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

    static func load(
        on database: any Database,
        language: String?,
        dayKey: String? = nil
    ) async throws -> [QuizOfTheDayQuestion] {
        if let dayKey {
            guard QuizCalendar.isValidDayKey(dayKey) else { throw Abort(.badRequest) }
            guard let day = try await QuizCalendarDayModel.find(dayKey, on: database) else {
                throw Abort(.notFound)
            }
            let questions = try await QuizBankQuestionModel.query(on: database)
                .filter(\.$id ~~ day.questionIDs)
                .all()
            let byID = Dictionary(uniqueKeysWithValues: questions.map { ($0.payload.id, $0.payload) })
            guard day.questionIDs.count == 15, byID.count == 15 else {
                throw Abort(.internalServerError, reason: "Incomplete quiz calendar day")
            }
            return try day.questionIDs.map { id in
                guard let entry = byID[id] else { throw Abort(.internalServerError) }
                return entry.response(language: language)
            }
        }
        let questions = try await QuizBankQuestionModel.query(on: database)
            .sort(\.$id)
            .limit(15)
            .all()
        return questions.map { $0.payload.response(language: language) }
    }
}
