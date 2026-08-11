import Testing
@testable import PerfumeSoulBackend

struct PerfumeNotesLoaderTests {
    @Test("Accept-Language parser prefers English for English first tag")
    func acceptLanguageParserPrefersEnglishForEnglishFirstTag() {
        #expect(PerfumeNotesLoader.prefersEnglish(acceptLanguage: "en"))
        #expect(PerfumeNotesLoader.prefersEnglish(acceptLanguage: "en-US"))
        #expect(PerfumeNotesLoader.prefersEnglish(acceptLanguage: " en-US "))
    }

    @Test("Accept-Language parser does not prefer English for non-English first tag")
    func acceptLanguageParserRejectsNonEnglishFirstTag() {
        #expect(!PerfumeNotesLoader.prefersEnglish(acceptLanguage: "ru"))
        #expect(!PerfumeNotesLoader.prefersEnglish(acceptLanguage: "*"))
        #expect(!PerfumeNotesLoader.prefersEnglish(acceptLanguage: nil))
    }

    @Test("Accept-Language parser keeps current first-tag behavior")
    func acceptLanguageParserKeepsFirstTagBehavior() {
        #expect(!PerfumeNotesLoader.prefersEnglish(acceptLanguage: "ru;q=0.2,en;q=0.9"))
    }
}
