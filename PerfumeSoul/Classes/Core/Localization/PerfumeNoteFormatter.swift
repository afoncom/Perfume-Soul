import Foundation

/// Keeps backend-localized note names ordered and unique for display.
enum PerfumeNoteFormatter {
    static func names(_ notes: [String]) -> [String] {
        var seen: Set<String> = []
        return notes.compactMap { note in
            let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return nil
            }
            return seen.insert(normalized(trimmed)).inserted ? trimmed : nil
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
