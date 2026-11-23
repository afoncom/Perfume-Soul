import Foundation

/// One client-owned translation source for note keys from every perfume endpoint.
enum PerfumeNoteFormatter {
    static func names(
        keys: [String]?,
        fallbackNames: [String],
        languageCode: String = SupportedAppLanguage.currentCode,
        bundle: Bundle = .main
    ) -> [String] {
        guard let keys, !keys.isEmpty else {
            return names(fallbackNames)
        }
        let localizedBundle = bundle.path(forResource: languageCode, ofType: "lproj")
            .flatMap(Bundle.init(path:)) ?? bundle
        return names(keys.enumerated().map { index, key in
            let fallback = fallbackNames.indices.contains(index) ? fallbackNames[index] : ""
            let components = key.split(separator: "_").map(String.init)
            let suffix = key == "marine_notes" ? "seaNotes"
                : (components.first ?? "") + components.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
            let lookupKey = "perfumeNote.\(suffix)"
            let translated = localizedBundle.localizedString(forKey: lookupKey, value: nil, table: nil)
            return translated == lookupKey || translated.isEmpty ? fallback : translated
        })
    }

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
