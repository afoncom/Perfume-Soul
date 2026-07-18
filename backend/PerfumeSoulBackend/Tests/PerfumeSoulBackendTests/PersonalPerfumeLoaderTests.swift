import Testing
@testable import PerfumeSoulBackend

struct PersonalPerfumeLoaderTests {
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

    @Test("Market segment ranking is deterministic")
    func deterministicSegmentRanking() {
        let request = PersonalPerfumesRequest(
            sun: .virgo,
            moon: .taurus,
            ascendant: .capricorn,
            elementBalance: ElementBalance(
                fire: 0,
                earth: 80,
                air: 10,
                water: 10
            )
        )

        let recommendations = PersonalPerfumeLoader.load(
            request: request,
            perfumeProfiles: makePerfumes()
        )

        #expect(recommendations.prefix(3).map(\.marketSegment) == [.luxury, .luxury, .luxury])
        #expect(recommendations.dropFirst(3).prefix(3).map(\.marketSegment) == [.daily, .daily, .daily])
        #expect(recommendations.suffix(3).map(\.marketSegment) == [.niche, .niche, .niche])
    }
}

private extension PersonalPerfumeLoaderTests {
    func makePerfumes() -> [PerfumeProfile] {
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

    func makePerfume(
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
