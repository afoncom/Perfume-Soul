import Testing
import Vapor
@testable import PerfumeSoulBackend

struct PerfumeRecommendationLoaderTests {
    @Test("Scoring and API note keys are independent of display language")
    func scoringUsesStableNoteKeys() async throws {
        let candidate = PerfumeProfile(id: 2, perfumeName: "Candidate", brandName: "Brand", topNotes: ["Бергамот"])
        let russian = PerfumeProfile(id: 1, perfumeName: "Source", brandName: "Brand", topNotes: ["Бергамот"])
        let english = PerfumeProfile(id: 1, perfumeName: "Source", brandName: "Brand", topNotes: ["Bergamot"])
        let ruResult = try await loadRecommendations(perfumeProfiles: [russian, candidate], selectedPerfumeIDs: [1])
        let enResult = try await loadRecommendations(perfumeProfiles: [english, candidate], selectedPerfumeIDs: [1])
        #expect(PerfumeRecommendationLoader.noteWeights(for: russian) == ["bergamot": 3])
        #expect(PerfumeRecommendationLoader.noteWeights(for: english) == ["bergamot": 3])
        #expect(ruResult.map(\.matchingNoteKeys) == [["bergamot"]])
        #expect(enResult.map(\.matchingNoteKeys) == ruResult.map(\.matchingNoteKeys))
        #expect(enResult.map(\.matchPercentage) == ruResult.map(\.matchPercentage))
        #expect(PerfumeNoteKey.key(for: "Редкая нота", id: 99) == "note:99")
        #expect(PerfumeNoteKey.key(for: "Морские ноты") == "marine_notes")
        #expect(PerfumeNoteKey.key(for: "Апельсиновый цвет") == "orange_blossom")
    }

    @Test("Equal Russian names retain distinct IDs, localized names and matches")
    func equalNamesRetainIdentity() async throws {
        func profile(id: Int, notes: [PerfumeProfileNote], language: String) -> PerfumeProfile {
            PerfumeProfile(
                id: id,
                perfumeName: "Perfume \(id)",
                brandName: "Brand",
                longevityScore: nil,
                sillageScore: nil,
                concentration: nil,
                fragranceFamily: nil,
                seasonProfile: nil,
                occasionProfile: nil,
                styleProfile: nil,
                genderProfile: nil,
                moodProfile: nil,
                marketSegment: nil,
                profileNotes: notes,
                profileAccords: [],
                language: language
            )
        }
        let blonde = PerfumeProfileNote(
            name: "Светлая древесина", nameEnglish: "Blonde Woods", noteType: .top, sortOrder: 0, id: 501
        )
        let white = PerfumeProfileNote(
            name: "Светлая древесина", nameEnglish: "White Woods", noteType: .top, sortOrder: 1, id: 502
        )
        for language in ["ru", "en"] {
            let source = profile(id: 1, notes: [blonde, white], language: language)
            let candidate = profile(id: 2, notes: [blonde], language: language)
            let other = profile(id: 3, notes: [white], language: language)
            #expect(PerfumeRecommendationLoader.noteWeights(for: source) == ["note:501": 3, "note:502": 3])
            #expect(candidate.signature != other.signature)
            let result = try await loadRecommendations(perfumeProfiles: [source, candidate, other], selectedPerfumeIDs: [1])
            #expect(result.count == 2)
            #expect(result.first { $0.id == 2 }?.matchingNoteKeys == ["note:501"])
            #expect(result.first { $0.id == 3 }?.matchingNoteKeys == ["note:502"])
            #expect(result.first { $0.id == 2 }?.matchingNotes == [language == "en" ? "Blonde Woods" : "Светлая древесина"])
            #expect(result.first { $0.id == 3 }?.matchingNotes == [language == "en" ? "White Woods" : "Светлая древесина"])
        }
    }

    @Test("SQL profile mapping preserves notes, accords and localized names")
    func sqlProfileMappingPreservesNotesAccordsAndLocalizedNames() throws {
        let row = SimilarPerfumeProfileRow(
            id: 1,
            perfumeName: "Perfume",
            brandName: "Brand",
            longevityScore: nil,
            sillageScore: nil,
            concentration: nil,
            fragranceFamily: nil,
            seasonProfile: nil,
            occasionProfile: nil,
            styleProfile: nil,
            genderProfile: nil,
            moodProfile: nil,
            marketSegment: "daily",
            notesJSON: "[{\"name\":\"Мускус\",\"nameEnglish\":\" Musk \",\"noteType\":\"base\",\"sortOrder\":1},{\"name\":\"Бергамот\",\"nameEnglish\":\" Bergamot \",\"noteType\":\"top\",\"sortOrder\":0}]",
            accordsJSON: "[{\"name\":\"citrus\",\"weight\":0.8}]"
        )

        let profile = try row.makeProfile(language: "en-US")

        #expect(profile.topNotes == ["Бергамот"])
        #expect(profile.baseNotes == ["Мускус"])
        #expect(profile.notes.first { $0.key == "bergamot" }?.displayName == "Bergamot")
        #expect(profile.accordWeights == ["citrus": 0.8])
    }

    @Test("Duplicate signatures are deduplicated after ranking")
    func duplicateSignaturesAreDeduplicated() async throws {
        let selectedPerfume = makeSelectedPerfume(id: 1)
        let firstDuplicate = PerfumeProfile(
            id: 2,
            perfumeName: "Alpha",
            brandName: "A Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
        let secondDuplicate = PerfumeProfile(
            id: 3,
            perfumeName: "Beta",
            brandName: "B Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
        let distinctCandidate = PerfumeProfile(
            id: 4,
            perfumeName: "Gamma",
            brandName: "C Brand",
            longevityScore: 6,
            sillageScore: 6,
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1]
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, firstDuplicate, secondDuplicate, distinctCandidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.id) == [2, 4])
    }

    @Test("Empty accords and optional metadata do not prevent scoring")
    func emptyAccordsAndMetadataStillProduceRecommendation() async throws {
        let selectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Selected",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"]
        )
        let candidate = PerfumeProfile(
            id: 2,
            perfumeName: "Candidate",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"]
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, candidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.count == 1)
        #expect(recommendations[0].id == 2)
        #expect(recommendations[0].matchPercentage > 0)
    }

    @Test("Matching notes use display names without changing scoring keys")
    func matchingNotesUseDisplayNamesWithoutChangingScoringKeys() async throws {
        let selectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Selected",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot"
            ]
        )
        let candidate = PerfumeProfile(
            id: 2,
            perfumeName: "Candidate",
            brandName: "Brand",
            topNotes: ["Бергамот"]
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, candidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.matchingNotes) == [["Bergamot"]])
    }

    @Test("Selected profiles keep request order for localized note display")
    func selectedProfilesKeepRequestOrderForLocalizedNoteDisplay() async throws {
        let firstRequested = PerfumeProfile(
            id: 1,
            perfumeName: "First Requested",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot First"
            ]
        )
        let secondRequested = PerfumeProfile(
            id: 2,
            perfumeName: "Second Requested",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot Second"
            ]
        )
        let candidate = PerfumeProfile(
            id: 3,
            perfumeName: "Candidate",
            brandName: "Brand",
            topNotes: ["Бергамот"]
        )

        let selectedProfiles = PerfumeRecommendationLoader.selectedProfiles(
            from: [secondRequested, firstRequested],
            orderedBy: [firstRequested.id, secondRequested.id]
        )
        let recommendations = try await PerfumeRecommendationLoader.loadRecommendations(
            selectedPerfumeProfiles: selectedProfiles,
            scoreRanges: ScoreRanges(longevityValues: [], sillageValues: []),
            pageSize: 1
        ) { afterID, _ in
            afterID == nil ? [candidate] : []
        }

        #expect(selectedProfiles.map(\.id) == [firstRequested.id, secondRequested.id])
        #expect(recommendations.map(\.matchingNotes) == [["Bergamot Second"]])
    }

    @Test("A missing display name falls back per note without changing other selected notes")
    func selectedPerfumesFallBackPerNote() async throws {
        let englishSelectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "English Selected",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot"
            ]
        )
        let fallbackSelectedPerfume = PerfumeProfile(
            id: 2,
            perfumeName: "Fallback Selected",
            brandName: "Brand",
            topNotes: ["Жасмин"]
        )
        let candidate = PerfumeProfile(
            id: 3,
            perfumeName: "Candidate",
            brandName: "Brand",
            topNotes: ["Бергамот", "Жасмин"]
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [englishSelectedPerfume, fallbackSelectedPerfume, candidate],
            selectedPerfumeIDs: [englishSelectedPerfume.id, fallbackSelectedPerfume.id]
        )

        #expect(recommendations.map(\.matchingNotes) == [["Bergamot", "Жасмин"]])
    }

    @Test("Matching notes keep the same cutoff before applying display names")
    func matchingNotesKeepSameCutoffBeforeApplyingDisplayNames() async throws {
        let selectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Selected",
            brandName: "Brand",
            topNotes: ["Бергамот", "Ваниль", "Жасмин", "Кедр", "Мускус", "Роза"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot",
                PerfumeRecommendationLoader.normalize("Ваниль"): "Vanilla",
                PerfumeRecommendationLoader.normalize("Жасмин"): "Jasmine",
                PerfumeRecommendationLoader.normalize("Кедр"): "Cedar",
                PerfumeRecommendationLoader.normalize("Мускус"): "Musk",
                PerfumeRecommendationLoader.normalize("Роза"): "Rose"
            ]
        )
        let candidate = PerfumeProfile(
            id: 2,
            perfumeName: "Candidate",
            brandName: "Brand",
            topNotes: ["Бергамот", "Ваниль", "Жасмин", "Кедр", "Мускус", "Роза"]
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, candidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.matchingNotes) == [["Bergamot", "Cedar", "Jasmine", "Musk", "Rose"]])
        #expect(recommendations.map(\.matchingNoteKeys) == [["bergamot", "cedar", "jasmine", "musk", "rose"]])
    }

    @Test("Equal scores use deterministic brand, perfume, and id tie-breakers")
    func deterministicTieBreakersForEqualScores() async throws {
        let selectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Selected",
            brandName: "Target",
            topNotes: ["Бергамот", "Лимон"]
        )
        let sameBrandFirstID = PerfumeProfile(
            id: 2,
            perfumeName: "Shared",
            brandName: "Alpha",
            topNotes: ["Бергамот"]
        )
        let sameBrandSecondID = PerfumeProfile(
            id: 3,
            perfumeName: "Shared",
            brandName: "Alpha",
            topNotes: ["Лимон"]
        )
        let laterBrand = PerfumeProfile(
            id: 4,
            perfumeName: "Another",
            brandName: "Beta",
            topNotes: ["Бергамот"],
            occasionProfile: "day"
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, sameBrandFirstID, sameBrandSecondID, laterBrand],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.id) == [2, 3, 4])
    }

    @Test("Both nil metadata is excluded from weighted string components")
    func bothNilMetadataDoesNotActAsMismatch() async throws {
        let selectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Selected",
            brandName: "Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"]
        )
        let candidateWithoutMetadata = PerfumeProfile(
            id: 2,
            perfumeName: "No Metadata",
            brandName: "Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"]
        )
        let candidateWithMismatchMetadata = PerfumeProfile(
            id: 3,
            perfumeName: "With Mismatch",
            brandName: "Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            fragranceFamily: "woody"
        )

        let recommendations = try await loadRecommendations(
            perfumeProfiles: [selectedPerfume, candidateWithoutMetadata, candidateWithMismatchMetadata],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.count == 2)
        #expect(recommendations[0].id == 2)
        #expect(recommendations[0].matchPercentage > recommendations[1].matchPercentage)
    }

    @Test("Paged similar finder keeps a best match beyond the first page")
    func pagedSimilarFinderKeepsBestMatchBeyondFirstPage() async throws {
        let selected = makeSelectedPerfume(id: 1)
        let weakerCandidate = PerfumeProfile(
            id: 2,
            perfumeName: "Weaker",
            brandName: "Brand A",
            topNotes: ["Бергамот"]
        )
        let bestCandidate = PerfumeProfile(
            id: 3,
            perfumeName: "Best",
            brandName: "Brand B",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
        let allProfiles = [selected, weakerCandidate, bestCandidate]

        let recommendations = try await PerfumeRecommendationLoader.loadRecommendations(
            selectedPerfumeProfiles: [selected],
            scoreRanges: ScoreRanges(
                longevityValues: [weakerCandidate, bestCandidate].compactMap(\.longevityScore),
                sillageValues: [weakerCandidate, bestCandidate].compactMap(\.sillageScore)
            ),
            pageSize: 2
        ) { afterID, limit in
            Array(allProfiles.filter { profile in
                afterID.map { profile.id > $0 } ?? true
            }.prefix(limit))
        }

        #expect(recommendations.first?.id == bestCandidate.id)
    }

    @Test("Paged similar finder keeps the best duplicate signature from a later page")
    func pagedSimilarFinderKeepsBestDuplicateSignatureFromLaterPage() async throws {
        let selected = makeSelectedPerfume(id: 1)
        let firstDuplicate = PerfumeProfile(
            id: 2,
            perfumeName: "Same Perfume",
            brandName: "Z Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
        let betterDuplicate = PerfumeProfile(
            id: 3,
            perfumeName: "Same Perfume",
            brandName: "A Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
        let allProfiles = [selected, firstDuplicate, betterDuplicate]

        let recommendations = try await PerfumeRecommendationLoader.loadRecommendations(
            selectedPerfumeProfiles: [selected],
            scoreRanges: ScoreRanges(
                longevityValues: [firstDuplicate, betterDuplicate].compactMap(\.longevityScore),
                sillageValues: [firstDuplicate, betterDuplicate].compactMap(\.sillageScore)
            ),
            pageSize: 1
        ) { afterID, limit in
            Array(allProfiles.filter { profile in
                afterID.map { profile.id > $0 } ?? true
            }.prefix(limit))
        }

        #expect(recommendations.map(\.id) == [betterDuplicate.id])
    }

    @Test("Similar finder excludes unclassified candidates")
    func similarFinderExcludesUnclassifiedCandidates() async throws {
        let selected = makeSelectedPerfume(id: 1)
        let unclassifiedCandidate = PerfumeProfile(
            id: 2,
            perfumeName: "Unclassified",
            brandName: "Brand A",
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6],
            marketSegment: "unclassified"
        )
        let eligibleCandidate = PerfumeProfile(
            id: 3,
            perfumeName: "Eligible",
            brandName: "Brand B",
            topNotes: ["Бергамот"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            marketSegment: "daily"
        )
        let profiles = [selected, unclassifiedCandidate, eligibleCandidate]

        let recommendations = try await PerfumeRecommendationLoader.loadRecommendations(
            selectedPerfumeProfiles: [selected],
            scoreRanges: ScoreRanges(
                longevityValues: [eligibleCandidate].compactMap(\.longevityScore),
                sillageValues: [eligibleCandidate].compactMap(\.sillageScore)
            ),
            pageSize: 2,
            eligibleMarketSegmentsOnly: true
        ) { afterID, limit in
            Array(profiles.filter { profile in
                afterID.map { profile.id > $0 } ?? true
            }.prefix(limit))
        }

        #expect(recommendations.map(\.id) == [eligibleCandidate.id])
    }
}

extension PerfumeRecommendationLoaderTests {
    func loadRecommendations(
        perfumeProfiles: [PerfumeProfile],
        selectedPerfumeIDs: [Int]
    ) async throws -> [PerfumeRecommendation] {
        let selectedPerfumeProfiles = selectedPerfumeIDs.compactMap { perfumeID in
            perfumeProfiles.first { $0.id == perfumeID }
        }
        guard selectedPerfumeProfiles.count == selectedPerfumeIDs.count else {
            throw Abort(.notFound)
        }
        let candidateProfiles = perfumeProfiles.filter { profile in
            !selectedPerfumeIDs.contains(profile.id)
        }

        return try await PerfumeRecommendationLoader.loadRecommendations(
            selectedPerfumeProfiles: selectedPerfumeProfiles,
            scoreRanges: ScoreRanges(
                longevityValues: candidateProfiles.compactMap(\.longevityScore),
                sillageValues: candidateProfiles.compactMap(\.sillageScore)
            ),
            pageSize: max(perfumeProfiles.count, 1)
        ) { afterID, limit in
            Array(perfumeProfiles.sorted { $0.id < $1.id }.filter { profile in
                afterID.map { profile.id > $0 } ?? true
            }.prefix(limit))
        }
    }

    func makeSelectedPerfume(id: Int) -> PerfumeProfile {
        PerfumeProfile(
            id: id,
            perfumeName: "Selected",
            brandName: "Target Brand",
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Лимон"],
            middleNotes: ["Жасмин"],
            baseNotes: ["Кедр"],
            accordWeights: ["citrus": 1, "fresh": 0.6]
        )
    }
}
