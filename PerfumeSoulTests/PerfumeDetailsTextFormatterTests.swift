import XCTest
@testable import PerfumeSoul

final class PerfumeDetailsTextFormatterTests: XCTestCase {
    private let backendAccords = [
        "amber", "aromatic", "boozy", "citrus", "earthy", "floral",
        "fresh", "fruity", "gourmand", "green", "leather", "marine",
        "musky", "powdery", "resinous", "smoky", "spicy", "woody"
    ]
    private let backendPhrases = [
        "all season", "autumn winter", "spring autumn", "spring summer",
        "fresh citrus", "floral citrus", "floral fruity", "floral woody",
        "fresh floral", "fresh woody", "marine fresh", "woody amber",
        "woody aromatic", "woody citrus", "woody floral", "woody leather",
        "woody spicy", "amber gourmand", "amber spicy", "amber woody",
        "fresh aromatic", "airy energetic", "balanced modern", "romantic soft", "dark sensual",
        "cozy indulgent", "refined grounded", "bright energetic",
        "warm indulgent", "rich sensual", "bright romantic"
    ]
    private let backendConcentrations = [
        "eau de toilette", "eau de parfum", "parfum", "extrait"
    ]

    func testLocalizedAccordCoversBackendVocabulary() {
        for accord in backendAccords {
            XCTAssertNotNil(
                PerfumeDetailsTextFormatter.localizedAccordKey(accord),
                "Missing localization for \(accord)"
            )
        }
    }

    func testLocalizedProfilePhraseCoversBackendVocabulary() {
        for phrase in backendPhrases {
            XCTAssertNotNil(
                PerfumeDetailsTextFormatter.localizedProfilePhraseKey(phrase),
                "Missing localization for \(phrase)"
            )
        }
    }

    func testLocalizedConcentrationCoversBackendVocabulary() {
        for concentration in backendConcentrations {
            XCTAssertNotEqual(
                PerfumeDetailsTextFormatter.localizedConcentration(concentration),
                concentration,
                "Missing localization for \(concentration)"
            )
        }
    }

    func testLocalizedProfilePhraseKeepsUnknownPhraseTogether() {
        XCTAssertEqual(
            PerfumeDetailsTextFormatter.localizedProfilePhrase("rare vintage profile"),
            "Rare vintage profile"
        )
    }

    func testLocalizedProfilePhraseFallsBackToLocalizedAccordTokens() {
        let accordLookup: (String) -> String? = { ["smoky": "Дымный", "woody": "древесный"][$0] }

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.localizedProfilePhrase(
                "smoky woody",
                accordLookup: accordLookup
            ),
            "Дымный древесный"
        )
    }

    func testMappedProfilePhrasesUseSameCasingAsFallback() throws {
        for phrase in backendPhrases {
            let mapped = PerfumeDetailsTextFormatter.localizedProfilePhrase(phrase)
            let unwrapped = try XCTUnwrap(mapped)
            let sentenceCased = unwrapped.prefix(1).uppercased() + unwrapped.dropFirst().lowercased()

            XCTAssertEqual(unwrapped, sentenceCased, "\(phrase) has unexpected casing")
        }
    }

    func testRecommendationReasonReturnsExplicitReason() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: "Best for warm evenings.",
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails),
            "Best for warm evenings."
        )
    }

    func testRecommendationReasonUsesMatchingLanguageNotes() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            notesLanguage: SupportedAppLanguage.currentCode,
            topNotes: ["Bergamot"]
        )

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails),
            L10n.PerfumeDetails.defaultRecommendationFormat("bergamot")
        )
    }

    func testRecommendationReasonRejectsFallbackOnlyReason() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: " ",
            notesLanguage: SupportedAppLanguage.currentCode,
            topNotes: []
        )

        XCTAssertNil(PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails))
    }

    func testRecommendationReasonRejectsMismatchedLanguageNotes() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            notesLanguage: "zz",
            topNotes: ["bergamot"]
        )

        XCTAssertNil(PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails))
    }

    func testRecommendationReasonRejectsNotesWithoutLanguage() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            notesLanguage: nil,
            topNotes: ["bergamot"]
        )

        XCTAssertNil(PerfumeDetailsTextFormatter.recommendationReason(for: perfumeDetails))
    }

    func testFullStoryReturnsTrimmedStory() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            fullStory: "\n A story shaped by incense. ",
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.fullStory(for: perfumeDetails),
            "A story shaped by incense."
        )
    }

    func testFullStoryRejectsBlankStory() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            fullStory: "\n  ",
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertNil(PerfumeDetailsTextFormatter.fullStory(for: perfumeDetails))
    }

    func testShortDescriptionPrefersTrimmedServerCopy() {
        let perfumeDetails = makePerfumeDetails(
            shortDescription: "  A radiant amber trail. ",
            recommendationReason: nil,
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.shortDescription(for: perfumeDetails),
            "A radiant amber trail."
        )
    }

    func testShortDescriptionFallsBackToFirstTwoLocalizedAccords() {
        let perfumeDetails = makePerfumeDetails(
            shortDescription: nil,
            recommendationReason: nil,
            accords: [
                PerfumeAccord(name: "Woody", weight: 1),
                PerfumeAccord(name: " amber ", weight: 0.9),
                PerfumeAccord(name: "citrus", weight: 0.8)
            ],
            notesLanguage: nil,
            topNotes: []
        )
        let accents = [
            L10n.PersonalPerfume.Accord.woody,
            L10n.PersonalPerfume.Accord.amber
        ].joined(separator: ", ")

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.shortDescription(for: perfumeDetails),
            L10n.PerfumeDetails.defaultSummaryFormat(accents)
        )
    }

    func testShortDescriptionFallsBackToDefaultSummaryWithoutAccords() {
        let perfumeDetails = makePerfumeDetails(
            shortDescription: nil,
            recommendationReason: nil,
            accords: [],
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertEqual(
            PerfumeDetailsTextFormatter.shortDescription(for: perfumeDetails),
            L10n.PerfumeDetails.defaultSummary
        )
    }

    private func makePerfumeDetails(
        shortDescription: String? = nil,
        recommendationReason: String?,
        fullStory: String? = nil,
        accords: [PerfumeAccord] = [],
        notesLanguage: String?,
        topNotes: [String]
    ) -> PerfumeDetails {
        PerfumeDetails(
            id: 1,
            brand: "Brand",
            name: "Perfume",
            concentration: nil,
            fragranceFamily: nil,
            seasonProfile: nil,
            occasionProfile: nil,
            styleProfile: nil,
            genderProfile: nil,
            moodProfile: nil,
            longevityScore: nil,
            sillageScore: nil,
            releaseYear: nil,
            perfumer: nil,
            shortDescription: shortDescription,
            recommendationReason: recommendationReason,
            fullStory: fullStory,
            accords: accords,
            notesLanguage: notesLanguage,
            topNotes: topNotes,
            middleNotes: [],
            baseNotes: []
        )
    }
}
