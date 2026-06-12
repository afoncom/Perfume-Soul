//
//  DailyQuizStateStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 08.06.2026.
//

import Foundation

protocol DailyQuizStateStorage {
    func loadState() -> DailyQuizState?
    func saveState(_ state: DailyQuizState)
    func clearState()
}

final class DailyQuizStateStorageImpl {
    private enum Keys {
        static let state = "quiz.dailyState"
    }

    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension DailyQuizStateStorageImpl: DailyQuizStateStorage {
    func loadState() -> DailyQuizState? {
        guard
            let data = userDefaults.data(forKey: Keys.state),
            let state = try? decoder.decode(DailyQuizState.self, from: data)
        else {
            return nil
        }

        return state
    }

    func saveState(_ state: DailyQuizState) {
        guard let data = try? encoder.encode(state) else {
            return
        }

        userDefaults.set(data, forKey: Keys.state)
    }

    func clearState() {
        userDefaults.removeObject(forKey: Keys.state)
    }
}
