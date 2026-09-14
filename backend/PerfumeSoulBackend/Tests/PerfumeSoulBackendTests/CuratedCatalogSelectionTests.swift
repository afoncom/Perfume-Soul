import Foundation
import Testing
@testable import PerfumeSoulBackend

@Test("CSV source decoder prefers UTF-8 before Latin-1 fallback")
func catalogSourceFileDecoderPrefersUTF8() throws {
    let decoded = try CatalogSourceFileDecoder.decode(Data("Chloé".utf8))

    #expect(decoded == "Chloé")
}

@Test("CSV source decoder falls back to Latin-1")
func catalogSourceFileDecoderFallsBackToLatin1() throws {
    let decoded = try CatalogSourceFileDecoder.decode(Data([0x43, 0x68, 0x6C, 0x6F, 0xE9]))

    #expect(decoded == "Chloé")
}

@Test("CSV parser preserves quoted semicolons in perfume fields")
func catalogCSVParserPreservesQuotedSemicolons() throws {
    let headers = [
        "url", "Perfume", "Brand", "Country", "Gender", "Rating Value", "Rating Count", "Year",
        "Top", "Middle", "Base", "Perfumer1", "Perfumer2", "mainaccord1", "mainaccord2",
        "mainaccord3", "mainaccord4", "mainaccord5"
    ]
    let values = [
        "https://example.com/perfume", "A; B", "Maison Test", "France", "unisex", "4.5", "10", "2024",
        "bergamot", "iris", "cedar", "Test Perfumer", "", "woody", "citrus", "powdery", "", ""
    ]
    let quotedValues = values.map { value in
        value.contains(";") ? "\"\(value)\"" : value
    }

    let parsed = try CatalogSourcePerfumeParser.parse(
        headers.joined(separator: ";") + "\n" + quotedValues.joined(separator: ";")
    )

    #expect(parsed.count == 1)
    #expect(parsed[0].perfumeName == "A; B")
    #expect(parsed[0].canonicalAccords == ["woody", "citrus", "powdery"])
}

@Test("CSV parser preserves a newline inside a quoted perfume field")
func catalogCSVParserPreservesQuotedNewlines() throws {
    let headers = [
        "url", "Perfume", "Brand", "Country", "Gender", "Rating Value", "Rating Count", "Year",
        "Top", "Middle", "Base", "Perfumer1", "Perfumer2", "mainaccord1", "mainaccord2",
        "mainaccord3", "mainaccord4", "mainaccord5"
    ]
    let values = [
        "https://example.com/perfume", "A\nB", "Maison Test", "France", "unisex", "4.5", "10", "2024",
        "bergamot", "iris", "cedar", "Test Perfumer", "", "woody", "citrus", "powdery", "", ""
    ]
    let quotedValues = values.map { value in
        value.contains("\n") ? "\"\(value)\"" : value
    }

    let parsed = try CatalogSourcePerfumeParser.parse(
        headers.joined(separator: ";") + "\n" + quotedValues.joined(separator: ";")
    )

    #expect(parsed.count == 1)
    #expect(parsed[0].perfumeName == "A\nB")
}

@Test("CSV parser reports a duplicate header instead of trapping")
func catalogCSVParserRejectsDuplicateHeaders() {
    #expect(throws: CatalogSourcePerfumeParserError.duplicateHeader("Perfume")) {
        try CatalogSourcePerfumeParser.parse("Perfume;Perfume\nA;B")
    }
}

@Test("Curated selector rejects incomplete profiles and enforces brand cap")
func curatedCatalogSelectorEnforcesRequirementsAndBrandCap() {
    let incomplete = catalogPerfume(
        name: "Incomplete",
        brand: "Maison A",
        ratingCount: 500,
        accords: ["woody"]
    )
    let strongestFromBrand = catalogPerfume(
        name: "Strongest",
        brand: "Maison A",
        ratingCount: 1000
    )
    let cappedFromBrand = catalogPerfume(
        name: "Capped",
        brand: "Maison A",
        ratingCount: 900
    )
    let anotherBrand = catalogPerfume(
        name: "Included",
        brand: "Maison B",
        ratingCount: 100
    )

    let result = CuratedCatalogSelector.select(
        from: [incomplete, strongestFromBrand, cappedFromBrand, anotherBrand],
        policy: CatalogSelectionPolicy(targetCount: 2, maximumPerBrand: 1)
    )

    #expect(result.selected.map(\.perfumeName) == ["Strongest", "Included"])
    #expect(result.rejected.contains { $0.reason == .incompleteProfile })
    #expect(result.rejected.contains { $0.reason == .brandCapReached })
}

@Test("Accord normalizer maps aliases, removes unknown values and deduplicates")
func catalogAccordNormalizerProducesControlledVocabulary() {
    let accords = CatalogAccordNormalizer.normalize([
        "White Floral", "warm spicy", "Aquatic", "white floral", "not-an-accord"
    ])

    #expect(accords == ["floral", "spicy", "marine"])
}

private func catalogPerfume(
    name: String,
    brand: String,
    ratingCount: Int,
    accords: [String] = ["woody", "citrus", "powdery"]
) -> CatalogSourcePerfume {
    CatalogSourcePerfume(
        sourceURL: "https://example.com/\(name)",
        perfumeName: name,
        brandName: brand,
        country: "France",
        gender: "unisex",
        rating: 4.0,
        ratingCount: ratingCount,
        releaseYear: 2024,
        topNotes: ["bergamot"],
        middleNotes: ["iris"],
        baseNotes: ["cedar"],
        perfumers: ["Test Perfumer"],
        accords: accords
    )
}
