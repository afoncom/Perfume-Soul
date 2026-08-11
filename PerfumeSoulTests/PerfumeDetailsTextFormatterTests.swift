import XCTest
@testable import PerfumeSoul

final class PerfumeDetailsTextFormatterTests: XCTestCase {
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

    func testLocalizedProfilePhraseCoversBackendVocabulary() {
        for phrase in backendPhrases {
            XCTAssertNotNil(
                PerfumeDetailsTextFormatter.localizedProfilePhraseKey(phrase),
                "Missing localization for \(phrase)"
            )
        }
    }

    func testLocalizedProfilePhraseKeepsUnknownPhraseTogether() {
        XCTAssertEqual(
            PerfumeDetailsTextFormatter.localizedProfilePhrase("rare vintage profile"),
            "Rare vintage profile"
        )
    }

    func testMappedProfilePhrasesUseSameCasingAsFallback() throws {
        for phrase in backendPhrases {
            let mapped = PerfumeDetailsTextFormatter.localizedProfilePhrase(phrase)
            let unwrapped = try XCTUnwrap(mapped)
            let sentenceCased = unwrapped.prefix(1).uppercased() + unwrapped.dropFirst()

            XCTAssertEqual(unwrapped, sentenceCased, "\(phrase) has unexpected casing")
        }
    }

    func testHasRecommendationContentAllowsExplicitReason() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: "Best for warm evenings.",
            notesLanguage: nil,
            topNotes: []
        )

        XCTAssertTrue(PerfumeDetailsTextFormatter.hasRecommendationContent(for: perfumeDetails))
    }

    func testHasRecommendationContentAllowsMatchingLanguageNotes() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: nil,
            notesLanguage: SupportedAppLanguage.currentCode,
            topNotes: ["bergamot"]
        )

        XCTAssertTrue(PerfumeDetailsTextFormatter.hasRecommendationContent(for: perfumeDetails))
    }

    func testHasRecommendationContentRejectsFallbackOnlyReason() {
        let perfumeDetails = makePerfumeDetails(
            recommendationReason: " ",
            notesLanguage: SupportedAppLanguage.currentCode,
            topNotes: []
        )

        XCTAssertFalse(PerfumeDetailsTextFormatter.hasRecommendationContent(for: perfumeDetails))
    }

    private func makePerfumeDetails(
        recommendationReason: String?,
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
            shortDescription: nil,
            recommendationReason: recommendationReason,
            fullStory: nil,
            accords: [],
            notesLanguage: notesLanguage,
            topNotes: topNotes,
            middleNotes: [],
            baseNotes: []
        )
    }
}
