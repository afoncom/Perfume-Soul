//
//  ViewStateStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.10.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol StorableViewState: Codable { }

final class ViewStateStorage<ViewState: StorableViewState> {
    private let userDefaults: UserDefaults
    private let storableKey: String
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        userDefaults: UserDefaults,
        storableKey: String
    ) {
        self.userDefaults = userDefaults
        self.storableKey = storableKey
    }

    func loadState() -> ViewState? {
        guard
            let data = userDefaults.data(forKey: storableKey),
            let state = try? decoder.decode(ViewState.self, from: data)
        else {
            return nil
        }

        return state
    }

    func saveState(_ state: ViewState) {
        guard let data = try? encoder.encode(state) else {
            return
        }

        userDefaults.set(data, forKey: storableKey)
    }

    func clearState() {
        userDefaults.removeObject(forKey: storableKey)
    }
}
