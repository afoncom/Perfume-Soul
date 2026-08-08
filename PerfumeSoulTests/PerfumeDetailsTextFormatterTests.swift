import XCTest
@testable import PerfumeSoul

final class PerfumeDetailsTextFormatterTests: XCTestCase {
    func testLocalizedProfilePhraseCoversBackendVocabulary() {
        let backendPhrases = [
            "all season", "autumn winter", "spring autumn", "spring summer",
            "fresh citrus", "floral citrus", "floral fruity", "floral woody",
            "fresh floral", "fresh woody", "marine fresh", "woody amber",
            "woody aromatic", "woody citrus", "woody floral", "woody leather",
            "woody spicy", "amber gourmand", "amber spicy", "amber woody",
            "fresh aromatic", "airy energetic", "balanced modern", "romantic soft", "dark sensual",
            "cozy indulgent", "refined grounded", "bright energetic",
            "warm indulgent", "rich sensual", "bright romantic"
        ]

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
            "Rare Vintage Profile"
        )
    }
}
