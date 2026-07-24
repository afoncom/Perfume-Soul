import Testing
@testable import PerfumeSoulBackend

struct PerfumeRecommendationLoaderTests {
    @Test("Duplicate signatures are deduplicated after ranking")
    func duplicateSignaturesAreDeduplicated() throws {
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

        let recommendations = try PerfumeRecommendationLoader.load(
            perfumeProfiles: [selectedPerfume, firstDuplicate, secondDuplicate, distinctCandidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.id) == [2, 4])
    }

    @Test("Empty accords and optional metadata do not prevent scoring")
    func emptyAccordsAndMetadataStillProduceRecommendation() throws {
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

        let recommendations = try PerfumeRecommendationLoader.load(
            perfumeProfiles: [selectedPerfume, candidate],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.count == 1)
        #expect(recommendations[0].id == 2)
        #expect(recommendations[0].matchPercentage > 0)
    }

    @Test("Equal scores use deterministic brand, perfume, and id tie-breakers")
    func deterministicTieBreakersForEqualScores() throws {
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

        let recommendations = try PerfumeRecommendationLoader.load(
            perfumeProfiles: [selectedPerfume, sameBrandFirstID, sameBrandSecondID, laterBrand],
            selectedPerfumeIDs: [selectedPerfume.id]
        )

        #expect(recommendations.map(\.id) == [2, 3, 4])
    }
}

extension PerfumeRecommendationLoaderTests {
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
