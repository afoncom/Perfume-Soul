//
//  QuizOfTheDayService.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

protocol QuizOfTheDayService {
    func requestQuizOfTheDayQuestions(
        version: QuizOfTheDayQuestion.SetVersion,
        dayKey: String?
    ) async throws -> [QuizOfTheDayQuestion]
}

final class QuizOfTheDayServiceImpl {
    private let requestManager: RequestManager

    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
}

extension QuizOfTheDayServiceImpl: QuizOfTheDayService {
    func requestQuizOfTheDayQuestions(
        version: QuizOfTheDayQuestion.SetVersion,
        dayKey: String?
    ) async throws -> [QuizOfTheDayQuestion] {
        let questions: [QuizOfTheDayResponse] = try await requestManager.sendRequest(
            request: QuizOfTheDayRequest(version: version, dayKey: dayKey)
        )
        return questions.map { QuizOfTheDayQuestion(response: $0) }
    }
}
