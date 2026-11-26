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
        return names(keys.enumerated().compactMap { index, key in
            localizedNote(
                key: key,
                fallbackName: fallbackNames.indices.contains(index) ? fallbackNames[index] : "",
                fallbackLanguage: nil,
                languageCode: languageCode,
                bundle: bundle
            )?.name
        })
    }

    struct LocalizedNote {
        let name: String
        let language: String?
    }

    static func localizedNote(
        key: String?,
        fallbackName: String,
        fallbackLanguage: String?,
        languageCode: String,
        bundle: Bundle
    ) -> LocalizedNote? {
        if let key {
            let localizedBundle = bundle.path(forResource: languageCode, ofType: "lproj")
                .flatMap(Bundle.init(path:)) ?? bundle
            let components = key.split(separator: "_").map(String.init)
            let suffix = key == "marine_notes" ? "seaNotes"
                : (components.first ?? "") + components.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
            let lookupKey = "perfumeNote.\(suffix)"
            let translated = localizedBundle.localizedString(forKey: lookupKey, value: nil, table: nil)
            if translated != lookupKey, !translated.isEmpty {
                return LocalizedNote(name: translated, language: languageCode)
            }
        }
        let fallback = fallbackName.trimmingCharacters(in: .whitespacesAndNewlines)
        return fallback.isEmpty ? nil : LocalizedNote(name: fallback, language: fallbackLanguage)
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
