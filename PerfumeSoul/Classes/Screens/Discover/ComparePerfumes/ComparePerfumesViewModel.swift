//
//  ComparePerfumesViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

enum ComparePerfumeField: Hashable, Identifiable {
    case left
    case right

    var id: Self { self }
}

@Observable final class ComparePerfumesViewModel {
    var leftSearchText = ""
    var rightSearchText = ""
    var leftSelectedPerfume: SearchPerfumeItem?
    var rightSelectedPerfume: SearchPerfumeItem?
    var searchResults: [SearchPerfumeItem] = []
    var isSearching = false
    var searchErrorMessage: String?
    var validationMessage: String?
    var isShowingValidationAlert = false
    var leftPerfume: ComparePerfume?
    var rightPerfume: ComparePerfume?
    var isLoading = false
    var hasLoadedOnce = false
    var errorMessage: String?

    var hasComparison: Bool {
        leftPerfume != nil && rightPerfume != nil
    }

    var canCompare: Bool {
        leftSelectedPerfume != nil && rightSelectedPerfume != nil
    }

    func title(for field: ComparePerfumeField) -> String {
        field == .left ? L10n.ComparePerfumes.leftPlaceholder : L10n.ComparePerfumes.rightPlaceholder
    }

    func symbol(for field: ComparePerfumeField) -> String {
        field == .left ? "A" : "B"
    }

    func selectedPerfume(for field: ComparePerfumeField) -> SearchPerfumeItem? {
        field == .left ? leftSelectedPerfume : rightSelectedPerfume
    }

    func selectionAccessibilityLabel(for field: ComparePerfumeField) -> String {
        [title(for: field), selectedPerfume(for: field)?.name]
            .compactMap { $0 }.joined(separator: ", ")
    }

    func isSharedNote(_ note: String, in notes: [String]) -> Bool {
        notes.contains { $0.localizedCaseInsensitiveCompare(note) == .orderedSame }
    }

    func displayNotes(_ notes: [String]) -> [String] {
        PerfumeNoteFormatter.names(notes)
    }

    func scoreText(_ score: Int?) -> String {
        score.map { "\($0) / 10" } ?? L10n.PerfumeDetails.emptyNotesPlaceholder
    }

    func scoreFraction(_ score: Int?) -> Double {
        Double(min(max(score ?? 0, 0), 10)) / 10
    }
}
