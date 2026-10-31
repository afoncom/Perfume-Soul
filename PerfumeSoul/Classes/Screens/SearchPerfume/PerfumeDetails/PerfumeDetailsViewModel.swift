//
//  PerfumeDetailsViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 20.06.2026.
//

import Foundation
import Observation

enum PerfumeDetailsSection: CaseIterable {
    case about
    case notes
    case wear

    var title: String {
        switch self {
        case .about: return String(localized: "perfumeDetails.about")
        case .notes: return L10n.PerfumeDetails.notesSectionTitle
        case .wear: return L10n.PerfumeDetails.onSkinSectionTitle
        }
    }
}

@Observable final class PerfumeDetailsViewModel {
    let perfume: SearchPerfumeItem
    var perfumeDetails: PerfumeDetails?
    var imageURL: URL?
    var isLoading = false
    var hasLoadedOnce = false
    var errorMessage: String?
    var isSaved = false

    init(perfume: SearchPerfumeItem) { self.perfume = perfume }

    var concentration: String? {
        guard let value = perfumeDetails?.concentration else {
            return nil
        }
        let known = ["eau de toilette", "eau de parfum", "parfum", "extrait"]
        guard known.contains(value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) else {
            return nil
        }
        return PerfumeDetailsTextFormatter.localizedConcentration(value)
    }

    var accords: [String] {
        (perfumeDetails?.accords ?? []).compactMap {
            PerfumeDetailsTextFormatter.localizedAccordKey($0.name.lowercased())?.localizedCapitalized
        }
    }

    var summary: String {
        guard let details = perfumeDetails else {
            return ""
        }
        if let summary = details.shortDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !summary.isEmpty {
            return summary
        }
        return accords.isEmpty
            ? L10n.PerfumeDetails.defaultSummary
            : L10n.PerfumeDetails.defaultSummaryFormat(accords.prefix(2).joined(separator: ", ").localizedLowercase)
    }

    var story: String? {
        perfumeDetails.flatMap { PerfumeDetailsTextFormatter.fullStory(for: $0) }
    }

    var recommendation: String? {
        perfumeDetails.flatMap { PerfumeDetailsTextFormatter.recommendationReason(for: $0) }
    }

    var hasLocalizedNotes: Bool {
        perfumeDetails?.notesLanguage?.lowercased() == SupportedAppLanguage.currentCode
    }

    var noteRows: [(title: String, notes: String)] {
        guard let details = perfumeDetails, hasLocalizedNotes else {
            return []
        }
        let notes = PerfumeDetailsTextFormatter.notes(for: details)
        return [
            (L10n.PerfumeDetails.topNotesTitle, notes.top),
            (L10n.PerfumeDetails.middleNotesTitle, notes.middle),
            (L10n.PerfumeDetails.baseNotesTitle, notes.base)
        ].map { ($0.0, $0.1.isEmpty ? L10n.PerfumeDetails.emptyNotesPlaceholder : $0.1.joined(separator: ", ")) }
    }

    var facts: [(title: String, value: String)] {
        guard let details = perfumeDetails else {
            return []
        }
        let values: [(String, String?)] = [
            (L10n.PerfumeDetails.releaseYearTitle, details.releaseYear.map(String.init)),
            (L10n.PerfumeDetails.perfumerTitle, details.perfumer),
            (L10n.PerfumeDetails.concentrationTitle, concentration),
            (L10n.PerfumeDetails.familyTitle, localizedPhrase(details.fragranceFamily)),
            (L10n.PerfumeDetails.seasonTitle, localizedPhrase(details.seasonProfile)),
            (L10n.PerfumeDetails.moodTitle, localizedPhrase(details.moodProfile))
        ]
        return values.compactMap { title, value in
            guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return (title, value)
        }
    }

    var wearRows: [(title: String, score: Int?)] {
        [
            (L10n.PerfumeDetails.longevityTitle, perfumeDetails?.longevityScore),
            (L10n.PerfumeDetails.sillageTitle, perfumeDetails?.sillageScore)
        ]
    }

    func scoreText(_ score: Int?) -> String {
        guard let score, (0...10).contains(score) else {
            return L10n.PerfumeDetails.emptyNotesPlaceholder
        }
        return "\(score)/10"
    }

    private func localizedPhrase(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let phrase = PerfumeDetailsTextFormatter.localizedProfilePhraseKey(normalized) {
            return phrase
        }
        let words = normalized.split(separator: " ").map(String.init)
        let translated = words.compactMap { PerfumeDetailsTextFormatter.localizedAccordKey($0) }
        guard !words.isEmpty, translated.count == words.count else {
            return nil
        }
        return translated.joined(separator: " ").localizedCapitalized
    }
}
