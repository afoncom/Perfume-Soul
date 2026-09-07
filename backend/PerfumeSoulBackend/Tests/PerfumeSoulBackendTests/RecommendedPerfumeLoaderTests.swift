import Testing
@testable import PerfumeSoulBackend

struct RecommendedPerfumeLoaderTests {
    @Test("Recommended candidates apply the brand cap before returning requested cards")
    func appliesBrandCapBeforeLimit() {
        let candidates = [
            makeCandidate(id: 1, brand: "A"), makeCandidate(id: 2, brand: "A"),
            makeCandidate(id: 3, brand: "A"), makeCandidate(id: 4, brand: "A"),
            makeCandidate(id: 5, brand: "A"), makeCandidate(id: 6, brand: "B"),
            makeCandidate(id: 7, brand: "C"), makeCandidate(id: 8, brand: "D"),
            makeCandidate(id: 9, brand: "E"), makeCandidate(id: 10, brand: "F"),
            makeCandidate(id: 11, brand: "G")
        ]

        let selected = RecommendedPerfumeCandidateLoader.candidatesApplyingBrandCap(candidates, limit: 8)

        #expect(selected.map(\.brandName).filter { $0 == "A" }.count == 2)
        #expect(selected.count == 8)
    }

    private func makeCandidate(id: Int, brand: String) -> DailyPerfumeCandidate {
        DailyPerfumeCandidate(id: id, perfumeName: "Perfume \(id)", brandName: brand, natalScore: Double(100 - id))
    }
}
