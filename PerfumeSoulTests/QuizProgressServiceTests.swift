import XCTest
@testable import PerfumeSoul

final class QuizProgressServiceTests: XCTestCase {
    func testLoadProgressMigratesExistingUserDefaultsProgress() async throws {
        let userDefaults = try makeUserDefaults()
        let legacyProgress = QuizProgress(
            streakDays: 4,
            lastCompletedQuizDayKey: "2026-10-18",
            correctAnswerKeys: ["2026-10-18_1", "2026-10-18_2"]
        )
        userDefaults.set(try JSONEncoder().encode(legacyProgress), forKey: "quiz.progress")
        let storage = QuizProgressDatabaseStorageMock()
        let service = QuizProgressServiceImpl(
            quizProgressStorage: storage,
            dayKeyProvider: QuizProgressDayKeyProviderMock(),
            userDefaults: userDefaults
        )

        let progress = await service.loadProgress()
        let storedModels = await storage.storedModels()

        XCTAssertEqual(progress, legacyProgress)
        XCTAssertEqual(storedModels, [legacyProgress])
    }

    func testLoadProgressRetriesMigrationWhenCoreDataSaveFails() async throws {
        let userDefaults = try makeUserDefaults()
        let legacyProgress = QuizProgress(
            streakDays: 2,
            lastCompletedQuizDayKey: "2026-10-18",
            correctAnswerKeys: ["2026-10-18_1"]
        )
        userDefaults.set(try JSONEncoder().encode(legacyProgress), forKey: "quiz.progress")
        let storage = QuizProgressDatabaseStorageMock(shouldPersist: false)
        let service = QuizProgressServiceImpl(
            quizProgressStorage: storage,
            dayKeyProvider: QuizProgressDayKeyProviderMock(),
            userDefaults: userDefaults
        )

        let firstLoad = await service.loadProgress()
        let secondLoad = await service.loadProgress()

        XCTAssertEqual(firstLoad, legacyProgress)
        XCTAssertEqual(secondLoad, legacyProgress)
        XCTAssertFalse(userDefaults.bool(forKey: "quiz.progress.didMigrateToCoreData"))
    }

    func testOverlappingUpdatesPreserveCorrectAnswerAndQuizCompletion() async {
        let storage = QuizProgressDatabaseStorageMock(
            models: [.initial],
            suspendsFirstSave: true
        )
        let service = QuizProgressServiceImpl(
            quizProgressStorage: storage,
            dayKeyProvider: QuizProgressDayKeyProviderMock()
        )

        let answerTask = Task {
            await service.recordCorrectAnswer(questionID: 7, quizDayKey: "2026-10-19")
        }
        await storage.waitUntilFirstSaveStarts()
        let completionTask = Task {
            await service.completeQuiz(for: "2026-10-19")
        }
        try? await Task.sleep(for: .milliseconds(50))
        await storage.resumeFirstSave()

        _ = await answerTask.value
        _ = await completionTask.value
        let progress = await service.loadProgress()

        XCTAssertEqual(progress.correctAnswerKeys, ["2026-10-19_7"])
        XCTAssertEqual(progress.lastCompletedQuizDayKey, "2026-10-19")
        XCTAssertEqual(progress.streakDays, 1)
    }

    private func makeUserDefaults() throws -> UserDefaults {
        let suiteName = "QuizProgressServiceTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        return userDefaults
    }
}

private final class QuizProgressDatabaseStorageMock: DatabaseStorage, @unchecked Sendable {
    typealias DatabaseModel = QuizProgress

    private actor State {
        var models: [QuizProgress]
        let shouldPersist: Bool
        let suspendsFirstSave: Bool
        var saveCount = 0
        var firstSaveStartedContinuation: CheckedContinuation<Void, Never>?
        var firstSaveResumeContinuation: CheckedContinuation<Void, Never>?
        var didStartFirstSave = false

        init(models: [QuizProgress], shouldPersist: Bool, suspendsFirstSave: Bool) {
            self.models = models
            self.shouldPersist = shouldPersist
            self.suspendsFirstSave = suspendsFirstSave
        }

        func replaceAll(with model: QuizProgress) async {
            saveCount += 1
            if suspendsFirstSave, saveCount == 1 {
                didStartFirstSave = true
                firstSaveStartedContinuation?.resume()
                firstSaveStartedContinuation = nil
                await withCheckedContinuation { continuation in
                    firstSaveResumeContinuation = continuation
                }
            }
            if shouldPersist {
                models = [model]
            }
        }

        func waitUntilFirstSaveStarts() async {
            if didStartFirstSave {
                return
            }
            await withCheckedContinuation { continuation in
                firstSaveStartedContinuation = continuation
            }
        }

        func resumeFirstSave() {
            firstSaveResumeContinuation?.resume()
            firstSaveResumeContinuation = nil
        }
    }

    private let state: State

    init(
        models: [QuizProgress] = [],
        shouldPersist: Bool = true,
        suspendsFirstSave: Bool = false
    ) {
        state = State(
            models: models,
            shouldPersist: shouldPersist,
            suspendsFirstSave: suspendsFirstSave
        )
    }

    func saveModel(model: QuizProgress) { }

    func replaceAll(with model: QuizProgress) async {
        await state.replaceAll(with: model)
    }

    func delete(model: QuizProgress) async { }

    func deleteAll() async { }

    func fechAll() async -> [QuizProgress] {
        await state.models
    }

    func storedModels() async -> [QuizProgress] {
        await state.models
    }

    func waitUntilFirstSaveStarts() async {
        await state.waitUntilFirstSaveStarts()
    }

    func resumeFirstSave() async {
        await state.resumeFirstSave()
    }
}

private final class QuizProgressDayKeyProviderMock: QuizDayKeyProvider {
    func todayKey() -> String { "2026-10-19" }
    func isCurrentOrPreviousDay(_ dayKey: String) -> Bool { true }
    func isNextDay(_ dayKey: String, after previousDayKey: String) -> Bool { false }
}
