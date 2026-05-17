//
//  QuizOfTheDayRequest.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.05.2026.
//

struct QuizOfTheDayRequest: Request {
    let path: String = "/quiz-of-the-day"
    let httpMethod: HTTPMethod = .get
}
