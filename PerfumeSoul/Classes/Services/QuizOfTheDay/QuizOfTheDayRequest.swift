//
//  QuizOfTheDayRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

import Foundation

struct QuizOfTheDayRequest: Request {
    let version: QuizOfTheDayQuestion.SetVersion
    var dayKey: String?

    var path: String {
        switch version {
        case .legacy:
            return "/quiz-of-the-day"
        case .bank, .calendar:
            return "/v2/quiz-of-the-day"
        }
    }

    let httpMethod: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        guard version == .calendar, let dayKey else {
            return []
        }
        return [URLQueryItem(name: "dayKey", value: dayKey)]
    }
}
