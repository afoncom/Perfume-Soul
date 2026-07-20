import Testing
import Vapor
@testable import PerfumeSoulBackend

struct PersonalPerfumeLoaderTests {
    @Test("Element balance validation accepts a valid 100 percent total")
    func validElementBalancePassesValidation() throws {
        try makeRequest(
            fire: 25,
            earth: 25,
            air: 25,
            water: 25
        ).validateElementBalance()
    }

    @Test("Element balance validation rejects negative values with bad request")
    func negativeElementBalanceFailsValidation() {
        expectBadRequest(
            fire: -1,
            earth: 34,
            air: 33,
            water: 34
        )
    }

    @Test("Element balance validation rejects values above 100 with bad request")
    func oversizedElementBalanceFailsValidation() {
        expectBadRequest(
            fire: 101,
            earth: 0,
            air: 0,
            water: -1
        )
    }

    @Test("Element balance validation rejects totals below 100 with bad request")
    func lowElementBalanceTotalFailsValidation() {
        expectBadRequest(
            fire: 25,
            earth: 25,
            air: 25,
            water: 24
        )
    }

    @Test("Element balance validation rejects totals above 100 with bad request")
    func highElementBalanceTotalFailsValidation() {
        expectBadRequest(
            fire: 25,
            earth: 25,
            air: 25,
            water: 26
        )
    }

    @Test("Personal perfume loader returns three perfumes per market segment")
    func returnsThreePerfumesPerMarketSegment() {
        let request = PersonalPerfumesRequest(
            sun: .leo,
            moon: .cancer,
            ascendant: .scorpio,
            elementBalance: ElementBalance(
                fire: 45,
                earth: 15,
                air: 10,
                water: 30
            )
        )

        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: makePerfumes()
        )

        #expect(recommendations.count == 9)
        #expect(recommendations.filter { $0.marketSegment == .luxury }.count == 3)
        #expect(recommendations.filter { $0.marketSegment == .daily }.count == 3)
        #expect(recommendations.filter { $0.marketSegment == .niche }.count == 3)
        #expect(recommendations.allSatisfy { $0.matchPercentage >= 0 && $0.matchPercentage <= 100 })
    }

    @Test("Known profile returns exact ranked perfume ids")
    func knownProfileReturnsExactRankedPerfumeIDs() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: makeAirRankingPerfumes()
        )

        #expect(recommendations.map(\.id) == [101, 102, 103])
        #expect(recommendations[0].matchPercentage > recommendations[1].matchPercentage)
        #expect(recommendations[1].matchPercentage > recommendations[2].matchPercentage)
    }

    @Test("Known profile ranking is independent from input order")
    func knownProfileRankingIsIndependentFromInputOrder() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: makeAirRankingPerfumes()
        )
        let reversedRecommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: makeAirRankingPerfumes().reversed()
        )

        #expect(recommendations.map(\.id) == reversedRecommendations.map(\.id))
        #expect(recommendations.map(\.matchPercentage) == reversedRecommendations.map(\.matchPercentage))
    }

    @Test("Equal scores use deterministic brand, perfume, and id tie-breakers")
    func equalScoresUseDeterministicTieBreakers() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: [
                makeTieBreakerPerfume(id: 4, brand: "Beta", name: "Another", note: "Дым"),
                makeTieBreakerPerfume(id: 3, brand: "Alpha", name: "Shared", note: "Табак"),
                makeTieBreakerPerfume(id: 2, brand: "Alpha", name: "Shared", note: "Уд")
            ]
        )

        #expect(recommendations.map(\.id) == [2, 3, 4])
    }

    @Test("Duplicate signatures are removed after ranking")
    func duplicateSignaturesAreRemovedAfterRanking() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: [
                makeAirRankingPerfume(id: 102, name: "Air Secondary", accordScale: 0.5),
                makeAirRankingPerfume(id: 101, name: "Air Primary", accordScale: 1),
                makeAirRankingPerfume(id: 201, name: "Air Primary Clone", accordScale: 1)
            ]
        )

        #expect(recommendations.map(\.id) == [101, 102])
    }

    @Test("Segment returns fewer than three perfumes without borrowing from another segment")
    func shortSegmentDoesNotBorrowFromAnotherSegment() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: [
                makeAirRankingPerfume(id: 101, name: "Daily Air", accordScale: 1),
                makeAirRankingPerfume(id: 301, name: "Luxury Air", segment: "luxury", accordScale: 1),
                makeAirRankingPerfume(id: 302, name: "Luxury Clean", segment: "luxury", accordScale: 0.7)
            ]
        )

        #expect(recommendations.map(\.marketSegment) == [.luxury, .luxury, .daily])
        #expect(recommendations.filter { $0.marketSegment == .luxury }.count == 2)
        #expect(recommendations.filter { $0.marketSegment == .daily }.count == 1)
    }

    @Test("Missing optional metadata still returns a bounded recommendation")
    func missingOptionalMetadataStillReturnsBoundedRecommendation() {
        let request = makeRequest(fire: 0, earth: 0, air: 100, water: 0)
        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: [
                PerfumeProfile(
                    id: 1,
                    perfumeName: "Minimal",
                    brandName: "Brand",
                    marketSegment: "daily"
                )
            ]
        )

        #expect(recommendations.count == 1)
        #expect(recommendations[0].matchPercentage >= 0)
        #expect(recommendations[0].matchPercentage <= 100)
    }

    @Test("Dominant element profile scores matching descriptors and wear higher than balanced profile")
    func dominantElementWeightsDescriptorsAndWearProportionally() {
        let firePerfume = PerfumeProfile(
            id: 1,
            perfumeName: "Fire Descriptor",
            brandName: "Brand",
            longevityScore: 7,
            sillageScore: 9,
            fragranceFamily: "spicy amber leather citrus",
            styleProfile: "bold glamorous strong",
            moodProfile: "warm energetic bold",
            marketSegment: "daily"
        )
        let fireDominantRequest = makeRequest(
            fire: 97,
            earth: 1,
            air: 1,
            water: 1
        )
        let balancedRequest = makeRequest(
            fire: 25,
            earth: 25,
            air: 25,
            water: 25
        )

        let fireDominantMatch = PersonalPerfumeLoader.load(
            request: fireDominantRequest,
            perfumeProfiles: [firePerfume]
        )[0].matchPercentage
        let balancedMatch = PersonalPerfumeLoader.load(
            request: balancedRequest,
            perfumeProfiles: [firePerfume]
        )[0].matchPercentage

        #expect(fireDominantMatch > balancedMatch)
    }
}

extension PersonalPerfumeLoaderTests {
    private func expectBadRequest(
        fire: Int,
        earth: Int,
        air: Int,
        water: Int
    ) {
        do {
            try makeRequest(
                fire: fire,
                earth: earth,
                air: air,
                water: water
            ).validateElementBalance()
            Issue.record("Expected elementBalance validation to fail")
        } catch let abort as Abort {
            #expect(abort.status == .badRequest)
        } catch {
            Issue.record("Expected Abort(.badRequest), got \(error)")
        }
    }

    private func makeRequest(
        fire: Int,
        earth: Int,
        air: Int,
        water: Int
    ) -> PersonalPerfumesRequest {
        PersonalPerfumesRequest(
            sun: .aquarius,
            moon: .aquarius,
            ascendant: .aquarius,
            elementBalance: ElementBalance(
                fire: fire,
                earth: earth,
                air: air,
                water: water
            )
        )
    }

    private func makePerfumes() -> [PerfumeProfile] {
        [
            makePerfume(id: 1, name: "Luxury Fire", brand: "Tom Ford", segment: "luxury", accords: ["amber": 1, "spicy": 0.9]),
            makePerfume(id: 2, name: "Luxury Water", brand: "Creed", segment: "luxury", accords: ["marine": 1, "floral": 0.8]),
            makePerfume(id: 3, name: "Luxury Earth", brand: "MFK", segment: "luxury", accords: ["woody": 1, "green": 0.6]),
            makePerfume(id: 4, name: "Luxury Air", brand: "PDM", segment: "luxury", accords: ["fresh": 1, "citrus": 0.8]),
            makePerfume(id: 5, name: "Daily Fire", brand: "Dior", segment: "daily", accords: ["amber": 0.9, "spicy": 0.7]),
            makePerfume(id: 6, name: "Daily Water", brand: "Chanel", segment: "daily", accords: ["marine": 0.9, "musky": 0.7]),
            makePerfume(id: 7, name: "Daily Earth", brand: "Armani", segment: "daily", accords: ["woody": 0.8, "earthy": 0.7]),
            makePerfume(id: 8, name: "Daily Air", brand: "Burberry", segment: "daily", accords: ["fresh": 0.9, "aromatic": 0.8]),
            makePerfume(id: 9, name: "Niche Fire", brand: "Byredo", segment: "niche", accords: ["smoky": 0.9, "leather": 0.8]),
            makePerfume(id: 10, name: "Niche Water", brand: "Diptyque", segment: "niche", accords: ["floral": 0.9, "powdery": 0.7]),
            makePerfume(id: 11, name: "Niche Earth", brand: "Le Labo", segment: "niche", accords: ["woody": 0.9, "green": 0.8]),
            makePerfume(id: 12, name: "Niche Air", brand: "Maison Margiela", segment: "niche", accords: ["fresh": 0.9, "musky": 0.6])
        ]
    }

    private func makeAirRankingPerfumes() -> [PerfumeProfile] {
        [
            makeAirRankingPerfume(id: 104, name: "No Match", accordScale: 0),
            makeAirRankingPerfume(id: 102, name: "Partial Air", accordScale: 0.5),
            makeAirRankingPerfume(id: 103, name: "Descriptor Air", accordScale: 0.2),
            makeAirRankingPerfume(id: 101, name: "Perfect Air", accordScale: 1)
        ]
    }

    private func makeAirRankingPerfume(
        id: Int,
        name: String,
        segment: String = "daily",
        accordScale: Double
    ) -> PerfumeProfile {
        if accordScale == 0 {
            return PerfumeProfile(
                id: id,
                perfumeName: name,
                brandName: "Brand",
                longevityScore: 9,
                sillageScore: 9,
                topNotes: ["Табак"],
                middleNotes: ["Кожа"],
                baseNotes: ["Уд"],
                accordWeights: ["smoky": 1, "leather": 1],
                fragranceFamily: "smoky leather",
                styleProfile: "dark formal",
                moodProfile: "dark sensual",
                marketSegment: segment
            )
        }

        return PerfumeProfile(
            id: id,
            perfumeName: name,
            brandName: "Brand",
            longevityScore: 5,
            sillageScore: 5,
            topNotes: ["Мята", "Лаванда", "Мускус", "Бергамот"],
            middleNotes: ["Лимон"],
            baseNotes: ["Мускус"],
            accordWeights: [
                "fresh": 1 * accordScale,
                "aromatic": 1 * accordScale,
                "musky": 1 * accordScale,
                "marine": 0.8 * accordScale,
                "citrus": 0.8 * accordScale
            ],
            fragranceFamily: accordScale >= 0.5 ? "fresh marine aromatic citrus" : "fresh",
            styleProfile: accordScale >= 0.5 ? "clean modern light" : "modern",
            moodProfile: accordScale >= 0.5 ? "airy clean bright" : "clean",
            marketSegment: segment
        )
    }

    private func makeTieBreakerPerfume(
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

    private func makePerfume(
        id: Int,
        name: String,
        brand: String,
        segment: String,
        accords: [String: Double]
    ) -> PerfumeProfile {
        PerfumeProfile(
            id: id,
            perfumeName: name,
            brandName: brand,
            longevityScore: 7,
            sillageScore: 7,
            topNotes: ["Бергамот", "Перец"],
            middleNotes: ["Жасмин", "Ирис"],
            baseNotes: ["Кедр", "Ваниль"],
            accordWeights: accords,
            fragranceFamily: accords.keys.sorted().joined(separator: " "),
            styleProfile: "modern elegant bold",
            moodProfile: "bright soft sensual",
            marketSegment: segment
        )
    }
}
