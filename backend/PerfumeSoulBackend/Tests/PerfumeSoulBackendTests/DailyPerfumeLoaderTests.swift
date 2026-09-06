import Testing
import Vapor
import VaporTesting
@testable import PerfumeSoulBackend

struct DailyPerfumeLoaderTests {
    @Test("Daily perfume candidates exclude previously shown ids before ranking")
    func excludesPreviouslyShownPerfumeIDs() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(excludedPerfumeIDs: [101]),
            perfumeProfiles: [
                makeAirPerfume(id: 101, name: "Best Air", accordScale: 1),
                makeAirPerfume(id: 102, name: "Second Air", accordScale: 0.5)
            ]
        )

        #expect(candidates.map(\.id) == [102])
    }

    @Test("Daily perfume candidates deduplicate matching perfume signatures after ranking")
    func deduplicatesMatchingPerfumeSignaturesAfterRanking() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(),
            perfumeProfiles: [
                makeAirPerfume(id: 102, name: "Second Air", accordScale: 0.5),
                makeAirPerfume(id: 101, name: "Best Air", accordScale: 1),
                makeAirPerfume(id: 201, name: "Best Air Clone", accordScale: 1)
            ]
        )

        #expect(candidates.map(\.id) == [101, 102])
    }

    @Test("Daily perfume candidates use stable brand name and id tie breakers")
    func usesDeterministicTieBreakers() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(),
            perfumeProfiles: [
                makeTieBreakerPerfume(id: 4, brand: "Beta", name: "Another", note: "Дым"),
                makeTieBreakerPerfume(id: 3, brand: "Alpha", name: "Shared", note: "Табак"),
                makeTieBreakerPerfume(id: 2, brand: "Alpha", name: "Shared", note: "Уд")
            ]
        )

        #expect(candidates.map(\.id) == [2, 3, 4])
    }

    @Test("Daily perfume candidates avoid the last shown brand when another brand is eligible")
    func avoidsLastShownBrandWhenAnotherBrandIsEligible() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(lastShownBrand: "  yesterday brand  "),
            perfumeProfiles: [
                makeAirPerfume(id: 101, name: "Yesterday", brand: "Yesterday Brand", accordScale: 1),
                makeAirPerfume(id: 102, name: "Different Brand", brand: "New Brand", accordScale: 0.5)
            ]
        )

        #expect(candidates.map(\.id) == [102])
    }

    @Test("Daily perfume candidates keep the last shown brand when it is the only eligible brand")
    func keepsLastShownBrandWhenItIsTheOnlyEligibleBrand() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(lastShownBrand: "Yesterday Brand"),
            perfumeProfiles: [
                makeAirPerfume(id: 101, name: "Yesterday", brand: "Yesterday Brand", accordScale: 1)
            ]
        )

        #expect(candidates.map(\.id) == [101])
    }

    @Test("Daily perfume candidates load every page and cap the pool at twenty")
    func loadsEveryPageAndCapsThePoolAtTwenty() async throws {
        let perfumes = (1...25).map { id in
            makeAirPerfume(id: id, name: "Air", concentration: "\(id)", accordScale: 1)
        }
        let request = makeRequest(limit: 50)

        let candidates = try await DailyPerfumeCandidateLoader.loadCandidates(
            request: request,
            pageSize: 10
        ) { offset, limit in
            Array(perfumes.dropFirst(offset).prefix(limit))
        }

        #expect(candidates.count == 20)
        #expect(candidates.map(\.id) == Array(1...20))
    }

    @Test("Daily perfume candidates ignore unclassified and insufficiently described perfumes")
    func excludesInvalidCatalogCandidates() async throws {
        let candidates = try await loadCandidates(
            request: makeRequest(),
            perfumeProfiles: [
                makeAirPerfume(id: 1, name: "Unclassified", segment: "unclassified", accordScale: 1),
                PerfumeProfile(id: 2, perfumeName: "Minimal", brandName: "Brand", marketSegment: "daily"),
                makeAirPerfume(id: 3, name: "Eligible", accordScale: 0.5)
            ]
        )

        #expect(candidates.map(\.id) == [3])
    }

    @Test("Daily perfume candidate request rejects a nonpositive limit")
    func rejectsNonpositiveLimit() {
        #expect(throws: Abort.self) {
            try makeRequest(limit: 0).validate()
        }
    }

    @Test("Daily perfume endpoint rejects a nonpositive candidate limit")
    func endpointRejectsNonpositiveLimit() async throws {
        try await withApp { app in
            try routes(app)

            try await app.testing().test(.POST, "/daily-perfume/candidates") { req in
                try req.content.encode(makeRequest(limit: 0))
            } afterResponse: { res in
                #expect(res.status == .badRequest)
            }
        }
    }
}

private extension DailyPerfumeLoaderTests {
    func loadCandidates(
        request: DailyPerfumeCandidatesRequest,
        perfumeProfiles: [PerfumeProfile]
    ) async throws -> [DailyPerfumeCandidate] {
        try await DailyPerfumeCandidateLoader.loadCandidates(
            request: request,
            pageSize: 100
        ) { _, _ in
            perfumeProfiles
        }
    }

    func makeRequest(
        excludedPerfumeIDs: [Int] = [],
        lastShownBrand: String? = nil,
        limit: Int = 20
    ) -> DailyPerfumeCandidatesRequest {
        DailyPerfumeCandidatesRequest(
            sun: .aquarius,
            moon: .aquarius,
            ascendant: .aquarius,
            elementBalance: ElementBalance(fire: 0, earth: 0, air: 100, water: 0),
            excludedPerfumeIDs: excludedPerfumeIDs,
            lastShownBrand: lastShownBrand,
            limit: limit
        )
    }

    func makeAirPerfume(
        id: Int,
        name: String,
        brand: String = "Brand",
        concentration: String? = nil,
        segment: String = "daily",
        accordScale: Double
    ) -> PerfumeProfile {
        PerfumeProfile(
            id: id,
            perfumeName: name,
            brandName: brand,
            longevityScore: 5,
            sillageScore: 5,
            topNotes: ["Мята", "Лаванда", "Мускус", "Бергамот"],
            middleNotes: ["Лимон"],
            baseNotes: ["Мускус"],
            accordWeights: [
                "fresh": accordScale,
                "aromatic": accordScale,
                "musky": accordScale,
                "marine": 0.8 * accordScale,
                "citrus": 0.8 * accordScale
            ],
            concentration: concentration,
            fragranceFamily: accordScale >= 0.5 ? "fresh marine aromatic citrus" : "fresh",
            styleProfile: accordScale >= 0.5 ? "clean modern light" : "modern",
            moodProfile: accordScale >= 0.5 ? "airy clean bright" : "clean",
            marketSegment: segment
        )
    }

    func makeTieBreakerPerfume(
        id: Int,
        brand: String,
        name: String,
        note: String
    ) -> PerfumeProfile {
        PerfumeProfile(
            id: id,
            perfumeName: name,
            brandName: brand,
            topNotes: [note],
            accordWeights: ["smoky": 1],
            fragranceFamily: "smoky",
            styleProfile: "dark",
            moodProfile: "dark",
            marketSegment: "daily"
        )
    }
}
