//
//  PerfumeCollectionStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import Foundation

protocol PerfumeCollectionStorage {
    func loadState() -> PerfumeCollectionState
    func saveState(_ state: PerfumeCollectionState)
    func clearState()
}

final class PerfumeCollectionStorageImpl {
    private enum Keys {
        static let state = "perfumeCollection.state"
        static let legacyDailyState = "dailyPerfume.state"
        static let didMigrateLegacyState = "perfumeCollection.didMigrateLegacyState"
    }

    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension PerfumeCollectionStorageImpl: PerfumeCollectionStorage {
    func loadState() -> PerfumeCollectionState {
        if let data = userDefaults.data(forKey: Keys.state),
            let state = try? decoder.decode(PerfumeCollectionState.self, from: data) {
            return state
        }

        guard !userDefaults.bool(forKey: Keys.didMigrateLegacyState) else {
            return .empty
        }

        guard
            let data = userDefaults.data(forKey: Keys.legacyDailyState),
            let legacyState = try? decoder.decode(DailyPerfumeState.self, from: data)
        else {
            return .empty
        }

        let migratedState = PerfumeCollectionState(
            savedPerfumes: legacyState.savedPerfumes.map {
                PerfumeCollectionPerfume(
                    id: $0.id,
                    perfumeName: $0.perfumeName,
                    brandName: $0.brandName,
                    source: .dailyPerfume
                )
            },
            dislikedPerfumeIDs: legacyState.dislikedPerfumeIDs
        )
        saveState(migratedState)
        userDefaults.set(true, forKey: Keys.didMigrateLegacyState)
        return migratedState
    }

    func saveState(_ state: PerfumeCollectionState) {
        guard let data = try? encoder.encode(state) else {
            return
        }

        userDefaults.set(data, forKey: Keys.state)
    }

    func clearState() {
        userDefaults.removeObject(forKey: Keys.state)
        userDefaults.set(true, forKey: Keys.didMigrateLegacyState)
    }
}
