import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct PerfumeNotesLoaderTests {
    @Test("Legacy details report the actual list language", arguments: [false, true])
    func detailsUseKeysAndPerNoteFallback(hasEnglishTranslation: Bool) async throws {
        let database = ArrayTestDatabase()
        database.append([PerfumeModel(id: 1, perfumeName: "Perfume", brandID: 1)])
        database.append([BrandModel(id: 1, name: "Brand")])
        database.append([
            PerfumeNoteModel(id: 1, perfumeID: 1, noteID: 10, noteType: .top, sortOrder: 0),
            PerfumeNoteModel(id: 2, perfumeID: 1, noteID: 99, noteType: .top, sortOrder: 1)
        ])
        database.append([
            NoteModel(id: 10, name: "Бергамот", nameEnglish: "Bergamot"),
            NoteModel(id: 99, name: "Редкая нота", nameEnglish: hasEnglishTranslation ? "Rare note" : nil)
        ])
        database.append([])
        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app)
            try await app.testing().test(.GET, "/perfumes/1/notes", headers: ["Accept-Language": "en"]) { response in
                #expect(response.status == .ok)
                let notes = try JSONDecoder().decode(PerfumeNotesResponse.self, from: Data(response.body.string.utf8))
                #expect(notes.topNotes == (hasEnglishTranslation ? ["Bergamot", "Rare note"] : ["Бергамот", "Редкая нота"]))
                #expect(notes.notesLanguage == (hasEnglishTranslation ? "en" : "ru"))
                #expect(notes.topNoteKeys == ["bergamot", "note:99"])
            }
        }
    }

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
