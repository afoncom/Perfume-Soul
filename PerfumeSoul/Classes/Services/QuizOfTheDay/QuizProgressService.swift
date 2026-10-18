//
//  QuizProgressService.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import CoreData

protocol QuizProgressService {
    func loadProgress() async -> QuizProgress
    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress
    func completeQuiz(for quizDayKey: String) async -> QuizProgress
    func resetProgress() async
}

final class QuizProgressServiceImpl<QuizProgressStorage: DatabaseStorage>
where QuizProgressStorage.DatabaseModel == QuizProgress {
    private let quizProgressStorage: QuizProgressStorage
    private let dayKeyProvider: QuizDayKeyProvider

    init(
        quizProgressStorage: QuizProgressStorage,
        dayKeyProvider: QuizDayKeyProvider
    ) {
        self.quizProgressStorage = quizProgressStorage
        self.dayKeyProvider = dayKeyProvider
    }
}

extension QuizProgressServiceImpl where QuizProgressStorage == DatabaseStorageImpl<QuizProgress> {
    convenience init(
        container: NSPersistentContainer,
        dayKeyProvider: QuizDayKeyProvider
    ) {
        self.init(
            quizProgressStorage: DatabaseStorageImpl<QuizProgress>(container: container),
            dayKeyProvider: dayKeyProvider
        )
    }
}

extension QuizProgressServiceImpl: QuizProgressService {
    func loadProgress() async -> QuizProgress {
        resolvedProgress(from: await storedProgress())
    }

    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress {
        var progress = await storedProgress()
        progress.correctAnswerKeys.insert(
            correctAnswerKey(
                questionID: questionID,
                quizDayKey: quizDayKey
            )
        )
        await saveProgress(progress)
        return resolvedProgress(from: progress)
    }

    func completeQuiz(for quizDayKey: String) async -> QuizProgress {
        var progress = await storedProgress()
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
        await saveProgress(progress)
        return progress
    }

    func resetProgress() async {
        await quizProgressStorage.deleteAll()
    }
}

extension QuizProgressServiceImpl {
    private func storedProgress() async -> QuizProgress {
        (await quizProgressStorage.fechAll()).first ?? .initial
    }

    private func saveProgress(_ progress: QuizProgress) async {
        await quizProgressStorage.replaceAll(with: progress)
    }

    private func correctAnswerKey(
        questionID: Int,
        quizDayKey: String
    ) -> String {
        "\(quizDayKey)_\(questionID)"
    }

    private func resolvedProgress(from progress: QuizProgress) -> QuizProgress {
        guard let lastCompletedQuizDayKey = progress.lastCompletedQuizDayKey else {
            return QuizProgress(
                streakDays: 0,
                lastCompletedQuizDayKey: nil,
                correctAnswerKeys: progress.correctAnswerKeys
            )
        }

        guard dayKeyProvider.isCurrentOrPreviousDay(lastCompletedQuizDayKey) else {
            return QuizProgress(
                streakDays: 0,
                lastCompletedQuizDayKey: lastCompletedQuizDayKey,
                correctAnswerKeys: progress.correctAnswerKeys
            )
        }

        return progress
    }
}
