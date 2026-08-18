import Foundation
import Testing

struct NoteEnglishNameSeedTests {
    @Test("Every seeded perfume note has an English name")
    func everySeededPerfumeNoteHasEnglishName() throws {
        let scriptsDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("scripts")
        let englishNamesSQL = try String(
            contentsOf: scriptsDirectory.appendingPathComponent("fill_note_english_names.sql"),
            encoding: .utf8
        )
        let accordSeedSQL = try String(
            contentsOf: scriptsDirectory.appendingPathComponent("fill_perfume_accords.sql"),
            encoding: .utf8
        )

        let mappedNotes = Set(
            englishNamesSQL.matches(of: /WHEN '([^']+)' THEN '[^']+'/).map { String($0.1) }
        )
        let seededNotes = Set(
            accordSeedSQL.matches(of: /\('([^']+)', '[^']+', [0-9.]+\)/).map { String($0.1) }
        )

        #expect(mappedNotes == seededNotes)
    }
}
