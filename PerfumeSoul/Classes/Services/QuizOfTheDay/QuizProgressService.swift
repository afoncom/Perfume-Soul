//
//  QuizProgressService.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import CoreData
import Foundation

protocol QuizProgressService {
    func loadProgress() async -> QuizProgress
    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress
    func completeQuiz(for quizDayKey: String) async -> QuizProgress
    func resetProgress() async
}

final class QuizProgressServiceImpl<QuizProgressStorage: DatabaseStorage>
where QuizProgressStorage.DatabaseModel == QuizProgress {
    private enum Keys {
        static var legacyProgress: String { "quiz.progress" }
        static var didMigrateToCoreData: String { "quiz.progress.didMigrateToCoreData" }
    }

    private actor OperationLock {
        private var isLocked = false
        private var waiters: [CheckedContinuation<Void, Never>] = []

        func acquire() async {
            guard isLocked else {
                isLocked = true
                return
            }

            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }

        func release() {
            guard !waiters.isEmpty else {
                isLocked = false
                return
            }

            waiters.removeFirst().resume()
        }
    }

    private let quizProgressStorage: QuizProgressStorage
    private let dayKeyProvider: QuizDayKeyProvider
    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let operationLock = OperationLock()

    init(
        quizProgressStorage: QuizProgressStorage,
        dayKeyProvider: QuizDayKeyProvider,
        userDefaults: UserDefaults = .standard
    ) {
        self.quizProgressStorage = quizProgressStorage
        self.dayKeyProvider = dayKeyProvider
        self.userDefaults = userDefaults
    }
}

extension QuizProgressServiceImpl where QuizProgressStorage == DatabaseStorageImpl<QuizProgress> {
    convenience init(
        container: NSPersistentContainer,
        dayKeyProvider: QuizDayKeyProvider,
        userDefaults: UserDefaults = .standard
    ) {
        self.init(
            quizProgressStorage: DatabaseStorageImpl<QuizProgress>(container: container),
            dayKeyProvider: dayKeyProvider,
            userDefaults: userDefaults
        )
    }
}

extension QuizProgressServiceImpl: QuizProgressService {
    func loadProgress() async -> QuizProgress {
        await withExclusiveAccess {
            resolvedProgress(from: await storedProgress())
        }
    }

    func recordCorrectAnswer(questionID: Int, quizDayKey: String) async -> QuizProgress {
        await withExclusiveAccess {
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
    }

    func completeQuiz(for quizDayKey: String) async -> QuizProgress {
        await withExclusiveAccess {
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
    }

    func resetProgress() async {
        await withExclusiveAccess {
            await quizProgressStorage.deleteAll()
            userDefaults.removeObject(forKey: Keys.legacyProgress)
            userDefaults.set(true, forKey: Keys.didMigrateToCoreData)
        }
    }
}

extension QuizProgressServiceImpl {
    private func storedProgress() async -> QuizProgress {
        if let progress = (await quizProgressStorage.fechAll()).first {
            return progress
        }

        return await migrateLegacyProgress() ?? .initial
    }

    private func saveProgress(_ progress: QuizProgress) async {
        await quizProgressStorage.replaceAll(with: progress)
    }

    private func migrateLegacyProgress() async -> QuizProgress? {
        guard !userDefaults.bool(forKey: Keys.didMigrateToCoreData) else {
            return nil
        }

        guard
            let data = userDefaults.data(forKey: Keys.legacyProgress),
            let progress = try? decoder.decode(QuizProgress.self, from: data)
        else {
            userDefaults.set(true, forKey: Keys.didMigrateToCoreData)
            return nil
        }

        await saveProgress(progress)

        guard (await quizProgressStorage.fechAll()).first == progress else {
            return progress
        }

        userDefaults.set(true, forKey: Keys.didMigrateToCoreData)
        userDefaults.removeObject(forKey: Keys.legacyProgress)
        return progress
    }

    private func withExclusiveAccess<Result>(
        _ operation: () async -> Result
    ) async -> Result {
        await operationLock.acquire()
        let result = await operation()
        await operationLock.release()
        return result
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
