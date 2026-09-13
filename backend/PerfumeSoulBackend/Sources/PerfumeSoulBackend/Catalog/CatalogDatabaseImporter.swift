import Fluent

struct CatalogImportBatchResult: Codable, Sendable {
    let requestedCount: Int
    let createdPerfumeCount: Int
    let skippedExistingPerfumeCount: Int
    let createdBrandCount: Int
    let createdNoteCount: Int
    let createdAccordCount: Int
}

enum CatalogDatabaseImporter {
    static func importBatch(
        _ sourcePerfumes: [CatalogSourcePerfume],
        on database: any Database
    ) async throws -> CatalogImportBatchResult {
        let preparedPerfumes = try sourcePerfumes.map(CatalogPreparedPerfume.init(source:))

        return try await database.transaction { database in
            var brandsByName = try await existingBrands(on: database)
            var notesByName = try await existingNotes(on: database)
            var accordsByName = try await existingAccords(on: database)
            var existingPerfumeKeys = try await existingPerfumeIdentities(on: database)

            var createdPerfumeCount = 0
            var skippedExistingPerfumeCount = 0
            var createdBrandCount = 0
            var createdNoteCount = 0
            var createdAccordCount = 0

            for perfume in preparedPerfumes {
                let brand = try await resolveBrand(
                    named: perfume.brandName,
                    brandsByName: &brandsByName,
                    createdCount: &createdBrandCount,
                    on: database
                )
                guard let brandID = brand.id else {
                    throw CatalogImportError.missingPersistedIdentifier
                }

                guard existingPerfumeKeys.insert(perfume.identity).inserted else {
                    skippedExistingPerfumeCount += 1
                    continue
                }

                let perfumeModel = PerfumeModel(
                    perfumeName: perfume.perfumeName,
                    fragranceFamily: perfume.accords.prefix(2).joined(separator: ", "),
                    genderProfile: perfume.genderProfile,
                    marketSegment: perfume.marketSegment,
                    releaseYear: perfume.releaseYear,
                    perfumer: perfume.perfumer,
                    brandID: brandID
                )
                try await perfumeModel.create(on: database)
                guard let perfumeID = perfumeModel.id else {
                    throw CatalogImportError.missingPersistedIdentifier
                }

                try await createNotes(
                    perfume.topNotes,
                    type: .top,
                    perfumeID: perfumeID,
                    notesByName: &notesByName,
                    createdCount: &createdNoteCount,
                    on: database
                )
                try await createNotes(
                    perfume.middleNotes,
                    type: .middle,
                    perfumeID: perfumeID,
                    notesByName: &notesByName,
                    createdCount: &createdNoteCount,
                    on: database
                )
                try await createNotes(
                    perfume.baseNotes,
                    type: .base,
                    perfumeID: perfumeID,
                    notesByName: &notesByName,
                    createdCount: &createdNoteCount,
                    on: database
                )
                try await createAccords(
                    perfume.accords,
                    perfumeID: perfumeID,
                    accordsByName: &accordsByName,
                    createdCount: &createdAccordCount,
                    on: database
                )
                createdPerfumeCount += 1
            }

            return CatalogImportBatchResult(
                requestedCount: sourcePerfumes.count,
                createdPerfumeCount: createdPerfumeCount,
                skippedExistingPerfumeCount: skippedExistingPerfumeCount,
                createdBrandCount: createdBrandCount,
                createdNoteCount: createdNoteCount,
                createdAccordCount: createdAccordCount
            )
        }
    }

    private static func existingBrands(on database: any Database) async throws -> [String: BrandModel] {
        let brands = try await BrandModel.query(on: database).all()
        return Dictionary(uniqueKeysWithValues: brands.map { (normalized($0.name), $0) })
    }

    private static func existingNotes(on database: any Database) async throws -> [String: NoteModel] {
        let notes = try await NoteModel.query(on: database).all()
        var notesByName: [String: NoteModel] = [:]
        for note in notes {
            notesByName[normalized(note.name)] = note
            if let englishName = note.nameEnglish {
                notesByName[normalized(englishName)] = note
            }
        }
        return notesByName
    }

    private static func existingAccords(on database: any Database) async throws -> [String: AccordModel] {
        let accords = try await AccordModel.query(on: database).all()
        return Dictionary(uniqueKeysWithValues: accords.map { (normalized($0.name), $0) })
    }

    static func existingPerfumeIdentities(on database: any Database) async throws -> Set<String> {
        let perfumes = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .all()
        return Set(perfumes.map { "\(normalized($0.brand.name))|\(normalized($0.perfumeName))" })
    }

    static func existingBrandCounts(on database: any Database) async throws -> [String: Int] {
        let perfumes = try await PerfumeModel.query(on: database)
            .with(\.$brand)
            .all()
        return perfumes.reduce(into: [String: Int]()) { counts, perfume in
            counts[normalized(perfume.brand.name), default: 0] += 1
        }
    }

    private static func resolveBrand(
        named name: String,
        brandsByName: inout [String: BrandModel],
        createdCount: inout Int,
        on database: any Database
    ) async throws -> BrandModel {
        let key = normalized(name)
        if let brand = brandsByName[key] {
            return brand
        }

        let brand = BrandModel(name: name)
        try await brand.create(on: database)
        brandsByName[key] = brand
        createdCount += 1
        return brand
    }

    private static func createNotes(
        _ names: [String],
        type: PerfumeNoteType,
        perfumeID: Int,
        notesByName: inout [String: NoteModel],
        createdCount: inout Int,
        on database: any Database
    ) async throws {
        var seenNames = Set<String>()
        for (index, englishName) in names.enumerated() {
            let key = normalized(englishName)
            guard seenNames.insert(key).inserted else {
                continue
            }

            let note = try await resolveNote(
                englishName: englishName,
                notesByName: &notesByName,
                createdCount: &createdCount,
                on: database
            )
            guard let noteID = note.id else {
                throw CatalogImportError.missingPersistedIdentifier
            }
            try await PerfumeNoteModel(
                perfumeID: perfumeID,
                noteID: noteID,
                noteType: type,
                sortOrder: index
            ).create(on: database)
        }
    }

    private static func resolveNote(
        englishName: String,
        notesByName: inout [String: NoteModel],
        createdCount: inout Int,
        on database: any Database
    ) async throws -> NoteModel {
        let key = normalized(englishName)
        if let note = notesByName[key] {
            return note
        }

        let displayName = CatalogNoteNameNormalizer.russianName(for: englishName) ?? englishName
        if let note = notesByName[normalized(displayName)] {
            notesByName[key] = note
            return note
        }

        let note = NoteModel(name: displayName, nameEnglish: englishName)
        try await note.create(on: database)
        notesByName[key] = note
        notesByName[normalized(displayName)] = note
        createdCount += 1
        return note
    }

    private static func createAccords(
        _ names: [String],
        perfumeID: Int,
        accordsByName: inout [String: AccordModel],
        createdCount: inout Int,
        on database: any Database
    ) async throws {
        for (index, name) in names.enumerated() {
            let key = normalized(name)
            let accord: AccordModel
            if let existingAccord = accordsByName[key] {
                accord = existingAccord
            } else {
                let createdAccord = AccordModel(name: name)
                try await createdAccord.create(on: database)
                accordsByName[key] = createdAccord
                createdCount += 1
                accord = createdAccord
            }

            guard let accordID = accord.id else {
                throw CatalogImportError.missingPersistedIdentifier
            }
            let weight = max(0.1, 1 - Double(index) * 0.15)
            try await PerfumeAccordModel(
                perfumeID: perfumeID,
                accordID: accordID,
                weight: weight
            ).create(on: database)
        }
    }
}

enum CatalogImportError: Error {
    case missingPersistedIdentifier
}
