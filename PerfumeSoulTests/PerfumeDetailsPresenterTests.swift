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

    func testPhotoHTTPFailureCanRecoverThroughTheRealServiceOnNextAppearance() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PhotoRecoveryURLProtocol.self]
        let session = URLSession(configuration: configuration)
        PhotoRecoveryURLProtocol.state.reset()
        defer {
            session.invalidateAndCancel()
            PhotoRecoveryURLProtocol.state.reset()
        }
        let service = PerfumeDetailsServiceImpl(requestManager: RequestManagerImpl(
            urlSession: session,
            baseURL: "https://photo-recovery.example"
        ))
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)

        await presenter.onAppear()

        XCTAssertEqual(viewModel.perfumeDetails?.name, "Sauvage")
        XCTAssertEqual(viewModel.perfumeDetails?.topNotes, ["Bergamot"])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.imageURL)

        await presenter.onAppear()

        XCTAssertEqual(viewModel.imageURL, URL(string: "https://cdn.fragella.com/images/dior-sauvage.jpg"))
        XCTAssertEqual(viewModel.perfumeDetails?.name, "Sauvage")
        XCTAssertEqual(viewModel.perfumeDetails?.topNotes, ["Bergamot"])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(PhotoRecoveryURLProtocol.state.requestCounts.images, 2)
        XCTAssertEqual(PhotoRecoveryURLProtocol.state.requestCounts.details, 1)
    }

    func testSuccessfulMissingPhotoIsNotRequestedAgainOnTheSameScreen() async {
        let service = PerfumeDetailsServiceStub()
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)

        await presenter.onAppear()
        service.imageProvider = { URL(string: "https://cdn.fragella.com/images/dior-sauvage.jpg") }
        await presenter.onAppear()

        XCTAssertNil(viewModel.imageURL)
        XCTAssertEqual(viewModel.perfumeDetails?.name, "Sauvage")
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

private final class PhotoRecoveryURLProtocol: URLProtocol {
    static let state = PhotoRecoveryState()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        let (status, body) = Self.state.response(for: url.path)
        guard let response = HTTPURLResponse(
            url: url, statusCode: status, httpVersion: nil, headerFields: ["Content-Type": "application/json"]
        ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

private final class PhotoRecoveryState: @unchecked Sendable {
    private let lock = NSLock()
    private var images = 0
    private var details = 0

    var requestCounts: (images: Int, details: Int) {
        lock.withLock { (images, details) }
    }

    func reset() {
        lock.withLock {
            images = 0
            details = 0
        }
    }

    func response(for path: String) -> (Int, String) {
        lock.withLock {
            switch path {
            case "/perfumes/1/notes":
                details += 1
                return (200, """
                {"id":1,"brand":"Dior","perfumeName":"Sauvage","topNotes":["Bergamot"],"middleNotes":[],"baseNotes":[]}
                """)
            case "/perfumes/1/image":
                images += 1
                if images == 1 {
                    return (503, #"{"error":true,"reason":"Image provider is unavailable."}"#)
                }
                return (200, #"{"imageURL":"https://cdn.fragella.com/images/dior-sauvage.jpg"}"#)
            default:
                return (404, #"{"error":true,"reason":"Not found."}"#)
            }
        }
    }
}
