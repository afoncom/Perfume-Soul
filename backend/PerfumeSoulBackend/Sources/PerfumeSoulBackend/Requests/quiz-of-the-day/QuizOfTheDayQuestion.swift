import Foundation

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
        let url = try resourceURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([QuizOfTheDayQuestion].self, from: data)
    }

    private static func resourceURL() throws -> URL {
        if let url = Bundle.module.url(forResource: "quiz-of-the-day", withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
