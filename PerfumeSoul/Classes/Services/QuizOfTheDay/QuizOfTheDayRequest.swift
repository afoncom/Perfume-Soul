//
//  QuizOfTheDayRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

struct QuizOfTheDayRequest: Request {
    let version: QuizOfTheDayQuestion.SetVersion

    var path: String {
        switch version {
        case .legacy:
            return "/quiz-of-the-day"
        case .bank:
            return "/v2/quiz-of-the-day"
        }
    }

    let httpMethod: HTTPMethod = .get
}
