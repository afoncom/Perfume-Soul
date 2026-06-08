//
//  QuizProgressService.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import Foundation

protocol QuizProgressService {
    func loadProgress() -> QuizProgress
    func recordCorrectAnswer(questionID: Int) -> QuizProgress
    func completeQuiz(for quizDayKey: String) -> QuizProgress
    func resetProgress()
}

final class QuizProgressServiceImpl {
    private enum Keys {
        static let progress = "quiz.progress"
    }

    private let userDefaults: UserDefaults
    private let dayKeyProvider: QuizDayKeyProvider
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        userDefaults: UserDefaults,
        dayKeyProvider: QuizDayKeyProvider
    ) {
        self.userDefaults = userDefaults
        self.dayKeyProvider = dayKeyProvider
    }

    private func storedProgress() -> QuizProgress {
        guard
            let data = userDefaults.data(forKey: Keys.progress),
            let progress = try? decoder.decode(QuizProgress.self, from: data)
        else {
            return .initial
        }

        return progress
    }

    private func saveProgress(_ progress: QuizProgress) {
        guard let data = try? encoder.encode(progress) else {
            return
        }

        userDefaults.set(data, forKey: Keys.progress)
    }

    private func resolvedProgress(from progress: QuizProgress) -> QuizProgress {
        guard let lastCompletedQuizDayKey = progress.lastCompletedQuizDayKey else {
            return QuizProgress(
                streakDays: 0,
                lastCompletedQuizDayKey: nil,
                correctQuestionIDs: progress.correctQuestionIDs
            )
        }

        guard dayKeyProvider.isCurrentOrPreviousDay(lastCompletedQuizDayKey) else {
            return QuizProgress(
                streakDays: 0,
                lastCompletedQuizDayKey: lastCompletedQuizDayKey,
                correctQuestionIDs: progress.correctQuestionIDs
            )
        }

        return progress
    }
}

extension QuizProgressServiceImpl: QuizProgressService {
    func loadProgress() -> QuizProgress {
        resolvedProgress(from: storedProgress())
    }

    func recordCorrectAnswer(questionID: Int) -> QuizProgress {
        var progress = storedProgress()
        progress.correctQuestionIDs.insert(questionID)
        saveProgress(progress)
        return resolvedProgress(from: progress)
    }

    func completeQuiz(for quizDayKey: String) -> QuizProgress {
        var progress = storedProgress()
        let resolvedProgress = resolvedProgress(from: progress)

        if progress.lastCompletedQuizDayKey == quizDayKey {
            return resolvedProgress
        }

        if
            let lastCompletedQuizDayKey = progress.lastCompletedQuizDayKey,
            dayKeyProvider.isNextDay(quizDayKey, after: lastCompletedQuizDayKey)
        {
            progress.streakDays = resolvedProgress.streakDays + 1
        } else {
            progress.streakDays = 1
        }

        progress.lastCompletedQuizDayKey = quizDayKey
        saveProgress(progress)
        return progress
    }

    func resetProgress() {
        userDefaults.removeObject(forKey: Keys.progress)
    }
}
