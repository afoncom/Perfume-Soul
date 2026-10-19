//
//  CatalogFavoritesStorage.swift
//  PerfumeSoul
//
//  Created by afon.com on 18.10.2026.
//


import Foundation

final class CatalogFavoritesStorage {
    private let userDefaults: UserDefaults
    private let key = "catalog.favoriteBrandIDs"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func load() -> Set<Int> {
        Set(userDefaults.array(forKey: key) as? [Int] ?? [])
    }

    func save(_ identifiers: Set<Int>) {
        userDefaults.set(identifiers.sorted(), forKey: key)
    }

    func clear() {
        userDefaults.removeObject(forKey: key)
    }
}
