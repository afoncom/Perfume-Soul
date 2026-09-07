//
//  PerfumeCollectionService.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import Foundation

protocol PerfumeCollectionService {
    func loadState() -> PerfumeCollectionState
    func save(_ perfume: PerfumeCollectionPerfume)
    func removeSavedPerfume(id: Int)
    func dislikePerfume(id: Int)
    func clearState()
}

final class PerfumeCollectionServiceImpl {
    private let storage: PerfumeCollectionStorage

    init(storage: PerfumeCollectionStorage) {
        self.storage = storage
    }
}

extension PerfumeCollectionServiceImpl: PerfumeCollectionService {
    func loadState() -> PerfumeCollectionState { storage.loadState() }

    func save(_ perfume: PerfumeCollectionPerfume) {
        var state = storage.loadState()
        guard !state.savedPerfumes.contains(where: { $0.id == perfume.id }) else {
            return
        }
        state.savedPerfumes.append(perfume)
        storage.saveState(state)
    }

    func removeSavedPerfume(id: Int) {
        var state = storage.loadState()
        state.savedPerfumes.removeAll { $0.id == id }
        storage.saveState(state)
    }

    func dislikePerfume(id: Int) {
        var state = storage.loadState()
        guard !state.dislikedPerfumeIDs.contains(id) else {
            return
        }
        state.dislikedPerfumeIDs.append(id)
        storage.saveState(state)
    }

    func clearState() { storage.clearState() }
}
