import XCTest
@testable import PerfumeSoul

final class PerfumeNoteFormatterTests: XCTestCase {
    private var localizationBundle: Bundle {
        #if SWIFT_PACKAGE
        Bundle.module
        #else
        Bundle.main
        #endif
    }

    func testSameNoteKeyHasSameNameAcrossAllThreeResponsesWithPerNoteFallback() throws {
        let detailsJSON = """
        {"id":1,"brand":"Brand","perfumeName":"Perfume", "topNoteKeys":["bergamot","note:99"],
        "notesLanguage":"ru","topNotes":["Бергамот","Редкая нота"],"middleNotes":[],"baseNotes":[]}
        """
        let recommendationsJSON = """
        {"id":1,"brandName":"Brand","perfumeName":"Perfume","matchingNoteKeys":["bergamot","note:99"],
        "matchingNotes":["Another legacy name","Редкая нота"],"matchPercentage":90}
        """
        let personalJSON = """
        {"id":1,"brandName":"Brand","perfumeName":"Perfume","marketSegment":"daily",
        "matchingNoteKeys":["bergamot"],"matchPercentage":90}
        """
        let details = try JSONDecoder().decode(PerfumeDetailsResponse.self, from: Data(detailsJSON.utf8))
        let recommendations = try JSONDecoder().decode(PerfumeRecommendationResponse.self, from: Data(recommendationsJSON.utf8))
        let personal = try JSONDecoder().decode(PersonalPerfumeResponse.self, from: Data(personalJSON.utf8))

        for language in ["en", "ru"] {
            let expected = language == "en" ? "Bergamot" : "Бергамот"
            let detailNotes = PerfumeDetails(response: details, languageCode: language, bundle: localizationBundle).topNotes
            let recommendedNotes = PerfumeRecommendation(
                response: recommendations, languageCode: language, bundle: localizationBundle
            ).matchingNotes
            let personalNotes = personal.localizedMatchingNotes(languageCode: language, bundle: localizationBundle)
            XCTAssertEqual(detailNotes, [expected, "Редкая нота"])
            XCTAssertEqual(recommendedNotes, detailNotes)
            XCTAssertEqual(personalNotes, [expected])
        }
    }

    func testExistingPersonalKeysUseTheSameLocalizationCatalog() {
        XCTAssertEqual(PerfumeNoteFormatter.names(
            keys: ["orange_blossom", "marine_notes"],
            fallbackNames: [],
            languageCode: "en",
            bundle: localizationBundle
        ), ["Orange Blossom", "Sea Notes"])
    }

    func testOldResponsesKeepNamesAndUnknownKeysDoNotLeakIntoDisplay() {
        XCTAssertEqual(PerfumeNoteFormatter.names(keys: nil, fallbackNames: [" Бергамот ", "Бергамот"]), ["Бергамот"])
        XCTAssertEqual(PerfumeNoteFormatter.names(keys: ["note:99"], fallbackNames: ["Rare note"]), ["Rare note"])
        XCTAssertEqual(PerfumeNoteFormatter.names(keys: ["note:99"], fallbackNames: []), [])
    }
}
