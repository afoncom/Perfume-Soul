import XCTest
@testable import PerfumeSoul

final class PersonalPerfumePresenterTests: XCTestCase {
    func testOnAppearPreservesResponseIDInPersonalPerfumeItem() async throws {
        let viewModel = PersonalPerfumeViewModel()
        let presenter = PersonalPerfumePresenterImpl(
            viewModel: viewModel,
            router: PersonalPerfumeRouterMock(),
            service: PersonalPerfumeServiceMock(),
            profileCalculation: try makeCalculation(),
            isPresentedInOnboarding: false,
            topStorage: PersonalPerfumeTopStorageMock(),
            recommendedStateStorage: RecommendedPerfumeStateStorageMock()
        )

        await presenter.onAppear()

        guard case let .content(sections) = viewModel.state else {
            return XCTFail("Expected personal perfume content")
        }

        XCTAssertEqual(sections.first?.perfumes.first?.id, 42)
    }

    @MainActor
    func testPerfumeTappedOpensExistingDetailsForSelectedItem() throws {
        let router = PersonalPerfumeRouterMock()
        let presenter = PersonalPerfumePresenterImpl(
            viewModel: PersonalPerfumeViewModel(),
            router: router,
            service: PersonalPerfumeServiceMock(),
            profileCalculation: try makeCalculation(),
            isPresentedInOnboarding: false,
            topStorage: PersonalPerfumeTopStorageMock(),
            recommendedStateStorage: RecommendedPerfumeStateStorageMock()
        )

        presenter.perfumeTapped(
            PersonalPerfumeItem(id: 42, name: "Test Brand", subtitle: "Test Perfume", matchPercentage: 95)
        )

        XCTAssertEqual(router.shownPerfume, SearchPerfumeItem(id: 42, name: "Test Perfume"))
    }
}

private final class PersonalPerfumeRouterMock: PersonalPerfumeRouter {
    var shownPerfume: SearchPerfumeItem?

    func finishOnboarding() { }
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) { shownPerfume = perfume }
}

private final class PersonalPerfumeServiceMock: PersonalPerfumeService {
    func requestPersonalPerfumes(profile: PersonalPerfumeProfileRequest) async throws -> [PersonalPerfumeResponse] {
        [PersonalPerfumeResponse(id: 42, perfumeName: "Test Perfume", brandName: "Test Brand", marketSegment: .luxury, matchPercentage: 95, longevityScore: nil, sillageScore: nil)]
    }
}

private final class PersonalPerfumeTopStorageMock: PersonalPerfumeTopStorage {
    func loadPerfumeIDs() -> [Int] { [] }
    func savePerfumeIDs(_ perfumeIDs: [Int]) { }
    func clear() { }
}

private final class RecommendedPerfumeStateStorageMock: RecommendedPerfumeStateStorage {
    func loadState() -> RecommendedPerfumeState? { nil }
    func saveState(_ state: RecommendedPerfumeState) { }
    func clearState() { }
}

private extension PersonalPerfumePresenterTests {
    func makeCalculation() throws -> ProfileCalculation {
        try JSONDecoder().decode(ProfileCalculation.self, from: Data("""
        { "natalChart": { "sun": { "sign": "aries", "longitude": 0 }, "moon": { "sign": "taurus", "longitude": 30 }, "ascendant": { "sign": "gemini", "longitude": 60 } }, "elementBalance": { "fire": 25, "earth": 25, "air": 25, "water": 25 } }
        """.utf8))
    }
}
