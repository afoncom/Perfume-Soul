import Foundation

/// Resolves catalog aliases once and chooses one display language for an entire result.
enum PerfumeNoteFormatter {
    static func language(for notes: [String]) -> String {
        guard SupportedAppLanguage.currentCode == "ru" else {
            return "en"
        }
        // An untranslated catalog term makes the whole group use its English names.
        // Never present a partly translated note pyramid.
        return notes.allSatisfy { keysByName[normalized($0)] != nil } ? "ru" : "en"
    }

    static func names(_ notes: [String], language: String) -> [String] {
        var seen: Set<String> = []
        return notes.compactMap { note in
            let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return nil
            }
            let name: String
            if let key = keysByName[normalized(trimmed)], let bundle = bundles[language] {
                name = bundle.localizedString(forKey: key, value: trimmed, table: nil)
            } else {
                name = trimmed
            }
            return seen.insert(normalized(name)).inserted ? name : nil
        }
    }

    private static let bundles: [String: Bundle] = ["ru", "en"].reduce(into: [:]) { result, language in
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            result[language] = bundle
        }
    }

    private static let keysByName: [String: String] = {
        var result: [String: String] = [:]
        for identifier in identifiers {
            let key = "perfumeNote.\(identifier)"
            for bundle in bundles.values {
                let name = bundle.localizedString(forKey: key, value: nil, table: nil)
                if name != key { result[normalized(name)] = key }
            }
        }
        let aliases = [
            "agarwood oud": "oud",
            "agarwood (oud)": "oud",
            "marine notes": "seaNotes",
            "tonka beans": "tonkaBean",
            "sandal": "sandalwood",
            "cedarwood": "cedar",
            "cedar wood": "cedar",
            "lily of the valley": "lilyOfTheValley",
            "blackcurrant": "blackCurrant",
            "black currant (cassis)": "blackCurrant",
            "mandarin": "mandarinOrange",
            "юзу": "yuzu",
            "водяная лилия": "waterLily"
        ]
        for (alias, identifier) in aliases {
            result[normalized(alias)] = "perfumeNote.\(identifier)"
        }
        return result
    }()

    private static func normalized(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static let identifiers: [String] = [
        "aldehydes",
        "amber",
        "ambergris",
        "ambroxan",
        "apple",
        "apricot",
        "basil",
        "benzoin",
        "bergamot",
        "birch",
        "blackCurrant",
        "blackPepper",
        "brazilianRosewood",
        "cardamom",
        "carnation",
        "caramel",
        "cashmeran",
        "cashmereWood",
        "cedar",
        "cherry",
        "cinnamon",
        "citruses",
        "clarySage",
        "cloves",
        "coconut",
        "coffee",
        "coriander",
        "cyclamen",
        "cypress",
        "damaskRose",
        "elemi",
        "fig",
        "figLeaf",
        "fir",
        "floralNotes",
        "freesia",
        "fruityNotes",
        "galbanum",
        "gardenia",
        "geranium",
        "ginger",
        "grapefruit",
        "greenNotes",
        "greenTea",
        "guaiacWood",
        "hawthorn",
        "heliotrope",
        "honey",
        "honeysuckle",
        "hyacinth",
        "incense",
        "iris",
        "isoESuper",
        "jasmine",
        "jasmineSambac",
        "juniper",
        "juniperBerries",
        "labdanum",
        "lavender",
        "leather",
        "lemon",
        "lemonVerbena",
        "lilac",
        "lily",
        "lilyOfTheValley",
        "lime",
        "lotus",
        "lychee",
        "magnolia",
        "mandarinOrange",
        "mate",
        "melon",
        "mimosa",
        "mint",
        "moss",
        "musk",
        "myrrh",
        "narcissus",
        "neroli",
        "nutmeg",
        "oakmoss",
        "orange",
        "orangeBlossom",
        "orrisRoot",
        "osmanthus",
        "oud",
        "patchouli",
        "peach",
        "pear",
        "peony",
        "pepper",
        "petitgrain",
        "pineapple",
        "pinkPepper",
        "plum",
        "powderyNotes",
        "raspberry",
        "rose",
        "rosemary",
        "rosewood",
        "rum",
        "saffron",
        "sage",
        "sandalwood",
        "seaNotes",
        "sichuanPepper",
        "smoke",
        "styrax",
        "suede",
        "tea",
        "tobacco",
        "tonkaBean",
        "tuberose",
        "vanilla",
        "vetiver",
        "violet",
        "violetLeaf",
        "waterJasmine",
        "waterLily",
        "waterNotes",
        "whiteFlowers",
        "whiteMusk",
        "woodyNotes",
        "ylangYlang",
        "yuzu"
    ]
}
