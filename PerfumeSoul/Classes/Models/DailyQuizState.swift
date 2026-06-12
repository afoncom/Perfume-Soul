//
//  DailyQuizState.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import Foundation

struct DailyQuizQuestionState: Codable, Equatable {
    let questionID: Int
    var selectedAnswerID: String?
    var isSubmitted: Bool
    var wasCorrect: Bool

    static func initial(questionID: Int) -> DailyQuizQuestionState {
        DailyQuizQuestionState(
            questionID: questionID,
            selectedAnswerID: nil,
            isSubmitted: false,
            wasCorrect: false
        )
    }
}

struct DailyQuizState: Codable, Equatable {
    let quizDayKey: String
    let questionIDs: [Int]
    var currentQuestionIndex: Int
    var questionStates: [DailyQuizQuestionState]
    var isCompleted: Bool

    static func initial(
        quizDayKey: String,
        questionIDs: [Int]
    ) -> DailyQuizState {
        DailyQuizState(
            quizDayKey: quizDayKey,
            questionIDs: questionIDs,
            currentQuestionIndex: 0,
            questionStates: questionIDs.map { DailyQuizQuestionState.initial(questionID: $0) },
            isCompleted: false
        )
    }

    func questionState(for questionID: Int) -> DailyQuizQuestionState? {
        questionStates.first(where: { $0.questionID == questionID })
    }

    mutating func updateQuestionState(
        questionID: Int,
        update: (inout DailyQuizQuestionState) -> Void
    ) {
        guard let stateIndex = questionStates.firstIndex(where: { $0.questionID == questionID }) else {
            return
        }

        update(&questionStates[stateIndex])
    }
}
