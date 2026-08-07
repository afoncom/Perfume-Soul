import Foundation

enum PerfumeDetailsTextFormatter {
    static func shortDescription(for perfumeDetails: PerfumeDetails) -> String {
        if let shortDescription = nonBlank(perfumeDetails.shortDescription) {
            return shortDescription
        }

        let accents = perfumeDetails.accords
            .prefix(2)
            .map { localizedAccord($0.name) }
            .joined(separator: ", ")

        guard !accents.isEmpty else {
            return L10n.PerfumeDetails.defaultSummary
        }

        return L10n.PerfumeDetails.defaultSummaryFormat(accents)
    }

    static func recommendationReason(for perfumeDetails: PerfumeDetails) -> String {
        if let recommendationReason = nonBlank(perfumeDetails.recommendationReason) {
            return recommendationReason
        }

        guard isRussianLocale else {
            return L10n.PerfumeDetails.defaultRecommendation
        }

        let notes = (perfumeDetails.topNotes + perfumeDetails.middleNotes + perfumeDetails.baseNotes)
            .compactMap(nonBlank)
            .prefix(3)
            .joined(separator: ", ")

        guard !notes.isEmpty else {
            return L10n.PerfumeDetails.defaultRecommendation
        }

        return L10n.PerfumeDetails.defaultRecommendationFormat(notes)
    }

    static func localizedConcentration(_ value: String?) -> String? {
        guard let value = nonBlank(value) else {
            return nil
        }

        switch normalized(value) {
        case "eau de toilette":
            return L10n.PerfumeDetails.Concentration.eauDeToilette
        case "eau de parfum":
            return L10n.PerfumeDetails.Concentration.eauDeParfum
        case "parfum":
            return L10n.PerfumeDetails.Concentration.parfum
        case "extrait":
            return L10n.PerfumeDetails.Concentration.extrait
        default:
            return value
        }
    }

    static func localizedProfilePhrase(_ value: String?) -> String? {
        guard let value = nonBlank(value) else {
            return nil
        }

        let normalizedValue = normalized(value)
        if let localizedPhrase = localizedProfilePhraseKey(normalizedValue) {
            return localizedPhrase
        }

        let tokens = normalizedValue
            .split(separator: " ")
            .map { localizedProfileToken(String($0)).localizedCapitalized }

        return tokens.joined(separator: " ")
    }

    static func localizedAccord(_ value: String) -> String {
        switch normalized(value) {
        case "amber": return L10n.PersonalPerfume.Accord.amber
        case "aromatic": return L10n.PersonalPerfume.Accord.aromatic
        case "boozy": return L10n.PerfumeDetails.Accord.boozy
        case "citrus": return L10n.PersonalPerfume.Accord.citrus
        case "earthy": return L10n.PersonalPerfume.Accord.earthy
        case "floral": return L10n.PersonalPerfume.Accord.floral
        case "fresh": return L10n.PersonalPerfume.Accord.fresh
        case "fruity": return L10n.PerfumeDetails.Accord.fruity
        case "gourmand": return L10n.PersonalPerfume.Accord.gourmand
        case "green": return L10n.PersonalPerfume.Accord.green
        case "leather": return L10n.PersonalPerfume.Accord.leather
        case "marine": return L10n.PersonalPerfume.Accord.marine
        case "musky": return L10n.PersonalPerfume.Accord.musky
        case "powdery": return L10n.PersonalPerfume.Accord.powdery
        case "resinous": return L10n.PerfumeDetails.Accord.resinous
        case "smoky": return L10n.PersonalPerfume.Accord.smoky
        case "spicy": return L10n.PersonalPerfume.Accord.spicy
        case "woody": return L10n.PersonalPerfume.Accord.woody
        default: return value
        }
    }

    private static func localizedProfileToken(_ token: String) -> String {
        switch normalized(token) {
        case "all": return L10n.PerfumeDetails.ProfileToken.all
        case "airy": return L10n.PerfumeDetails.ProfileToken.airy
        case "autumn": return L10n.PerfumeDetails.ProfileToken.autumn
        case "balanced": return L10n.PerfumeDetails.ProfileToken.balanced
        case "bright": return L10n.PerfumeDetails.ProfileToken.bright
        case "cozy": return L10n.PerfumeDetails.ProfileToken.cozy
        case "dark": return L10n.PerfumeDetails.ProfileToken.dark
        case "energetic": return L10n.PerfumeDetails.ProfileToken.energetic
        case "grounded": return L10n.PerfumeDetails.ProfileToken.grounded
        case "indulgent": return L10n.PerfumeDetails.ProfileToken.indulgent
        case "modern": return L10n.PerfumeDetails.ProfileToken.modern
        case "refined": return L10n.PerfumeDetails.ProfileToken.refined
        case "romantic": return L10n.PerfumeDetails.ProfileToken.romantic
        case "rich": return L10n.PerfumeDetails.ProfileToken.rich
        case "season": return L10n.PerfumeDetails.ProfileToken.season
        case "sensual": return L10n.PerfumeDetails.ProfileToken.sensual
        case "soft": return L10n.PerfumeDetails.ProfileToken.soft
        case "spring": return L10n.PerfumeDetails.ProfileToken.spring
        case "summer": return L10n.PerfumeDetails.ProfileToken.summer
        case "warm": return L10n.PerfumeDetails.ProfileToken.warm
        case "winter": return L10n.PerfumeDetails.ProfileToken.winter
        default: return localizedAccord(token)
        }
    }

    static func localizedProfilePhraseKey(_ phrase: String) -> String? {
        switch phrase {
        case "all season": return L10n.PerfumeDetails.ProfilePhrase.allSeason
        case "autumn winter": return L10n.PerfumeDetails.ProfilePhrase.autumnWinter
        case "spring autumn": return L10n.PerfumeDetails.ProfilePhrase.springAutumn
        case "spring summer": return L10n.PerfumeDetails.ProfilePhrase.springSummer
        case "fresh citrus": return L10n.PerfumeDetails.ProfilePhrase.freshCitrus
        case "floral citrus": return L10n.PerfumeDetails.ProfilePhrase.floralCitrus
        case "floral woody": return L10n.PerfumeDetails.ProfilePhrase.floralWoody
        case "marine fresh": return L10n.PerfumeDetails.ProfilePhrase.marineFresh
        case "woody amber": return L10n.PerfumeDetails.ProfilePhrase.woodyAmber
        case "woody spicy": return L10n.PerfumeDetails.ProfilePhrase.woodySpicy
        case "fresh woody": return L10n.PerfumeDetails.ProfilePhrase.freshWoody
        case "amber woody": return L10n.PerfumeDetails.ProfilePhrase.amberWoody
        case "amber spicy": return L10n.PerfumeDetails.ProfilePhrase.amberSpicy
        case "floral fruity": return L10n.PerfumeDetails.ProfilePhrase.floralFruity
        case "fresh floral": return L10n.PerfumeDetails.ProfilePhrase.freshFloral
        case "amber gourmand": return L10n.PerfumeDetails.ProfilePhrase.amberGourmand
        case "woody leather": return L10n.PerfumeDetails.ProfilePhrase.woodyLeather
        case "woody aromatic": return L10n.PerfumeDetails.ProfilePhrase.woodyAromatic
        case "woody citrus": return L10n.PerfumeDetails.ProfilePhrase.woodyCitrus
        case "woody floral": return L10n.PerfumeDetails.ProfilePhrase.woodyFloral
        case "fresh aromatic": return L10n.PerfumeDetails.ProfilePhrase.freshAromatic
        case "airy energetic": return L10n.PerfumeDetails.ProfilePhrase.airyEnergetic
        case "balanced modern": return L10n.PerfumeDetails.ProfilePhrase.balancedModern
        case "romantic soft": return L10n.PerfumeDetails.ProfilePhrase.romanticSoft
        case "dark sensual": return L10n.PerfumeDetails.ProfilePhrase.darkSensual
        case "cozy indulgent": return L10n.PerfumeDetails.ProfilePhrase.cozyIndulgent
        case "refined grounded": return L10n.PerfumeDetails.ProfilePhrase.refinedGrounded
        case "bright energetic": return L10n.PerfumeDetails.ProfilePhrase.brightEnergetic
        case "warm indulgent": return L10n.PerfumeDetails.ProfilePhrase.warmIndulgent
        case "rich sensual": return L10n.PerfumeDetails.ProfilePhrase.richSensual
        case "bright romantic": return L10n.PerfumeDetails.ProfilePhrase.brightRomantic
        default: return nil
        }
    }

    private static var isRussianLocale: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("ru") == true
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func nonBlank(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
