import Testing
import Vapor
@testable import PerfumeSoulBackend

struct PerfumeRecommendationLoaderTests {
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
        #expect(profile.noteDisplayNames["бергамот"] == "Bergamot")
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
            ],
            usesLocalizedNoteDisplayNames: true
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
            ],
            usesLocalizedNoteDisplayNames: true
        )
        let secondRequested = PerfumeProfile(
            id: 2,
            perfumeName: "Second Requested",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot Second"
            ],
            usesLocalizedNoteDisplayNames: true
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

    @Test("Selected perfumes fall back to base note names when any selected display map is incomplete")
    func selectedPerfumesFallBackToBaseNoteNamesWhenAnyDisplayMapIsIncomplete() async throws {
        let englishSelectedPerfume = PerfumeProfile(
            id: 1,
            perfumeName: "English Selected",
            brandName: "Brand",
            topNotes: ["Бергамот"],
            noteDisplayNames: [
                PerfumeRecommendationLoader.normalize("Бергамот"): "Bergamot"
            ],
            usesLocalizedNoteDisplayNames: true
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

        #expect(recommendations.map(\.matchingNotes) == [["Бергамот", "Жасмин"]])
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
            ],
            usesLocalizedNoteDisplayNames: true
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

        #expect(recommendations.map(\.matchingNotes) == [["Bergamot", "Vanilla", "Jasmine", "Cedar", "Musk"]])
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
