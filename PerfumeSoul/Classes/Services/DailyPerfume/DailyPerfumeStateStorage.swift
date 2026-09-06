//
//  DailyPerfumeStateStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol DailyPerfumeStateStorage {
    func loadState() -> DailyPerfumeState?
    func saveState(_ state: DailyPerfumeState)
    func clearState()
}

final class DailyPerfumeStateStorageImpl {
    private enum Keys {
        static let state = "dailyPerfume.state"
    }

    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension DailyPerfumeStateStorageImpl: DailyPerfumeStateStorage {
    func loadState() -> DailyPerfumeState? {
        guard
            let data = userDefaults.data(forKey: Keys.state),
            let state = try? decoder.decode(DailyPerfumeState.self, from: data)
        else {
            return nil
        }

        return state
    }

    func saveState(_ state: DailyPerfumeState) {
        guard let data = try? encoder.encode(state) else {
            return
        }

        userDefaults.set(data, forKey: Keys.state)
    }

    func clearState() {
        userDefaults.removeObject(forKey: Keys.state)
    }
}
