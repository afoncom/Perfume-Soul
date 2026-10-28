import XCTest
@testable import PerfumeSoul

@MainActor
final class PerfumeDetailsPresenterTests: XCTestCase {
    func testDelayedPhotoDoesNotHideLoadedDetails() async throws {
        let service = PerfumeDetailsServiceStub()
        let started = expectation(description: "Photo request started")
        var continuation: CheckedContinuation<URL?, any Error>?
        service.imageProvider = {
            try await withCheckedThrowingContinuation {
                continuation = $0
                started.fulfill()
            }
        }
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)
        let loading = Task { await presenter.onAppear() }
        await fulfillment(of: [started], timeout: 2)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertEqual(viewModel.perfumeDetails?.name, "Sauvage")
        XCTAssertEqual(viewModel.perfumeDetails?.topNotes, ["Bergamot"])
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.imageURL)

        let imageURL = URL(string: "https://cdn.fragella.com/images/dior-sauvage.jpg")
        continuation?.resume(returning: imageURL)
        await loading.value
        XCTAssertEqual(viewModel.imageURL, imageURL)
    }

    func testFailingPhotoDoesNotClearLoadedDetailsOrShowDetailsError() async {
        let service = PerfumeDetailsServiceStub()
        service.imageProvider = { throw URLError(.timedOut) }
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))

        await makePresenter(viewModel: viewModel, service: service).onAppear()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertEqual(viewModel.perfumeDetails?.brand, "Dior")
        XCTAssertEqual(viewModel.perfumeDetails?.topNotes, ["Bergamot"])
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.imageURL)
    }

    func testRepeatedAppearanceKeepsLoadedPhotoWithoutAnotherRequest() async {
        let service = PerfumeDetailsServiceStub()
        let imageURL = URL(string: "https://cdn.fragella.com/images/dior-sauvage.jpg")
        service.imageProvider = { imageURL }
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)

        await presenter.onAppear()
        service.imageProvider = { throw URLError(.notConnectedToInternet) }
        await presenter.onAppear()

        XCTAssertEqual(viewModel.imageURL, imageURL)
        XCTAssertNil(viewModel.errorMessage)
    }

    private func makePresenter(
        viewModel: PerfumeDetailsViewModel,
        service: PerfumeDetailsService
    ) -> PerfumeDetailsPresenterImpl {
        PerfumeDetailsPresenterImpl(
            viewModel: viewModel,
            router: PerfumeDetailsRouterImpl(),
            perfumeDetailsService: service,
            collectionService: PerfumeDetailsCollectionStub()
        )
    }
}

private final class PerfumeDetailsServiceStub: PerfumeDetailsService {
    var imageProvider: @MainActor () async throws -> URL? = { nil }

    func requestPerfumeDetails(perfumeID: Int) async throws -> PerfumeDetails {
        let response = try JSONDecoder().decode(PerfumeDetailsResponse.self, from: Data("""
        {"id":1,"brand":"Dior","perfumeName":"Sauvage","topNotes":["Bergamot"],"middleNotes":[],"baseNotes":[]}
        """.utf8))
        return PerfumeDetails(response: response)
    }

    func requestPerfumeImage(perfumeID: Int) async throws -> URL? {
        try await imageProvider()
    }
}

private final class PerfumeDetailsCollectionStub: PerfumeCollectionService {
    func loadState() -> PerfumeCollectionState { .empty }
    func save(_ perfume: PerfumeCollectionPerfume) { }
    func removeSavedPerfume(id: Int) { }
    func dislikePerfume(id: Int) { }
    func clearState() { }
}
