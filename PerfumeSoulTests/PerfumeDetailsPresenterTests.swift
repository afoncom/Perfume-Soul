import SwiftUI
import UIKit
import XCTest
@testable import PerfumeSoul

@MainActor
final class PerfumeDetailsPresenterTests: XCTestCase {
    func testRepeatedAppearanceDoesNotReloadDetails() async {
        let service = PerfumeDetailsServiceStub()
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)

        await presenter.onAppear()
        await presenter.onAppear()

        XCTAssertEqual(service.requests, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertEqual(viewModel.perfumeDetails?.topNotes, ["Bergamot"])
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFailedDetailsShowAnError() async {
        let service = PerfumeDetailsServiceStub()
        service.shouldFail = true
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))

        await makePresenter(viewModel: viewModel, service: service).onAppear()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.hasLoadedOnce)
        XCTAssertNil(viewModel.perfumeDetails)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testRetryRecoversDetailsAfterFailure() async {
        let service = PerfumeDetailsServiceStub()
        service.shouldFail = true
        let viewModel = PerfumeDetailsViewModel(perfume: SearchPerfumeItem(id: 1, name: "Sauvage"))
        let presenter = makePresenter(viewModel: viewModel, service: service)
        await presenter.onAppear()

        service.shouldFail = false
        await presenter.retryTapped()

        XCTAssertEqual(service.requests, 2)
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertEqual(viewModel.perfumeDetails?.name, "Sauvage")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testCatalogPhotoIsVisibleInDetailsWhenSeparateImageEndpointFails() async throws {
        try await expectWarmCatalogPhotoInDetails(legacyEndpoint: .failing)
    }

    func testCatalogPhotoIsVisibleInDetailsWhenSeparateImageEndpointIsDelayed() async throws {
        try await expectWarmCatalogPhotoInDetails(legacyEndpoint: .delayed)
    }

    func testDetailsPhotoIsReusedByCatalogWithoutResolvingURLAgain() async throws {
        let session = makePhotoSession(legacyEndpoint: .successful)
        defer { session.invalidateAndCancel() }
        let manager = RequestManagerImpl(urlSession: session, baseURL: "https://photos.example")
        let loader = makeImageLoader(session: session, manager: manager)
        let details = PerfumeDetailsModule.build(
            perfume: SearchPerfumeItem(id: 1, name: "Sauvage"), requestManager: manager, imageLoader: loader
        )
        let window = show(details)
        defer { window.isHidden = true; window.rootViewController = nil }

        let detailsShowsPhoto = await containsPhoto(in: details.view)
        XCTAssertTrue(detailsShowsPhoto, "Details should display the photo through the shared ID cache")
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/catalog/perfumes/1/image"), 1)
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/perfumes/1/image"), 0)

        let card = UIHostingController(rootView: CatalogPerfumeImage(
            perfume: CatalogPerfume(id: 1, name: "Sauvage", brand: "Dior", brandID: nil), loader: loader
        ).frame(width: 200, height: 200))
        window.rootViewController = card
        let catalogShowsPhoto = await containsPhoto(in: card.view)
        XCTAssertTrue(catalogShowsPhoto)
        XCTAssertNotNil(loader.cachedImage(for: 1))
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/catalog/perfumes/1/image"), 1)
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/bottle.png"), 1)
    }

    private func expectWarmCatalogPhotoInDetails(legacyEndpoint: LegacyPhotoEndpoint) async throws {
        let session = makePhotoSession(legacyEndpoint: legacyEndpoint)
        defer { session.invalidateAndCancel() }
        let manager = RequestManagerImpl(urlSession: session, baseURL: "https://photos.example")
        let loader = makeImageLoader(session: session, manager: manager)
        let catalog = CatalogPerfume(id: 1, name: "Sauvage", brand: "Dior", brandID: nil)
        let warmedPhoto = try await loader.image(for: catalog)
        XCTAssertNotNil(warmedPhoto)
        let details = PerfumeDetailsModule.build(
            perfume: SearchPerfumeItem(id: 1, name: "Sauvage"), requestManager: manager, imageLoader: loader
        )
        let window = show(details)
        defer { window.isHidden = true; window.rootViewController = nil }

        let detailsShowsPhoto = await containsPhoto(in: details.view)
        XCTAssertTrue(detailsShowsPhoto, "A warmed catalog photo must be visible without a separate image request")
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/perfumes/1/notes"), 1)
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/perfumes/1/image"), 0)
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/catalog/perfumes/1/image"), 1)
        XCTAssertEqual(DetailsPhotoURLProtocol.state.count(for: "/bottle.png"), 1)
    }

    private func makePhotoSession(legacyEndpoint: LegacyPhotoEndpoint) -> URLSession {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let fixture = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16), format: format).pngData { context in
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 16, height: 16))
        }
        DetailsPhotoURLProtocol.state.reset(legacyEndpoint: legacyEndpoint, photo: fixture)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [DetailsPhotoURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makeImageLoader(session: URLSession, manager: RequestManager) -> PerfumeImageLoader {
        PerfumeImageLoader(session: session, cacheDirectory: nil) { id in
            let response: CatalogPerfumeImageResponse = try await manager.sendRequest(
                request: CatalogPerfumeImageRequest(perfumeID: id)
            )
            return response.imageURL
        }
    }

    private func show(_ controller: UIViewController) -> UIWindow {
        let window: UIWindow
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            window = UIWindow(windowScene: scene)
            window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        } else {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        }
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        return window
    }

    private func containsPhoto(in view: UIView) async -> Bool {
        // The fixture is solid magenta; no production UI element uses this color.
        // Check actual rendered content so an omitted perfumeID cannot pass on cache assertions alone.
        for _ in 0..<50 {
            await Task.yield()
            view.layoutIfNeeded()
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let snapshot = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            if hasFixturePixels(snapshot) {
                return true
            }
            try? await Task.sleep(for: .milliseconds(40))
        }
        return false
    }

    private func hasFixturePixels(_ image: UIImage) -> Bool {
        guard let image = image.cgImage else {
            return false
        }
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        return pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }
            context.draw(image, in: CGRect(x: 0, y: 0, width: Double(width), height: Double(height)))
            let data = buffer.bindMemory(to: UInt8.self)
            var matches = 0
            for index in stride(from: 0, to: data.count, by: 4)
                where data[index] > 240 && data[index + 1] < 15 && data[index + 2] > 240 {
                matches += 1
                if matches > 1000 {
                    return true
                }
            }
            return false
        }
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
    var shouldFail = false
    private(set) var requests = 0

    func requestPerfumeDetails(perfumeID: Int) async throws -> PerfumeDetails {
        requests += 1
        if shouldFail { throw URLError(.timedOut) }
        let response = try JSONDecoder().decode(PerfumeDetailsResponse.self, from: Data(DetailsPhotoState.notes.utf8))
        return PerfumeDetails(response: response)
    }

}

private final class PerfumeDetailsCollectionStub: PerfumeCollectionService {
    func loadState() -> PerfumeCollectionState { .empty }
    func save(_ perfume: PerfumeCollectionPerfume) { }
    func removeSavedPerfume(id: Int) { }
    func dislikePerfume(id: Int) { }
    func clearState() { }
}

private enum LegacyPhotoEndpoint { case successful, failing, delayed }

private final class DetailsPhotoURLProtocol: URLProtocol, @unchecked Sendable {
    static let state = DetailsPhotoState()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            return
        }
        guard let (status, data) = Self.state.response(for: url.path) else {
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

private final class DetailsPhotoState: @unchecked Sendable {
    static let notes = #"{"id":1,"brand":"Dior","perfumeName":"Sauvage","topNotes":["Bergamot"],"middleNotes":[],"baseNotes":[]}"#
    private static let metadata = Data(#"{"imageURL":"https://photos.example/bottle.png"}"#.utf8)
    private let lock = NSLock()
    private var counts: [String: Int] = [:]
    private var legacyEndpoint: LegacyPhotoEndpoint = .successful
    private var photo = Data()

    func count(for path: String) -> Int { lock.withLock { counts[path, default: 0] } }

    func reset(legacyEndpoint: LegacyPhotoEndpoint, photo: Data) {
        lock.withLock {
            counts = [:]
            self.legacyEndpoint = legacyEndpoint
            self.photo = photo
        }
    }

    func response(for path: String) -> (Int, Data)? {
        lock.withLock {
            counts[path, default: 0] += 1
            switch path {
            case "/perfumes/1/notes": return (200, Data(Self.notes.utf8))
            case "/bottle.png": return (200, photo)
            case "/perfumes/1/image":
                if legacyEndpoint == .delayed {
                    return nil
                }
                if legacyEndpoint == .failing {
                    return (503, Data())
                }
                return (200, Self.metadata)
            case "/catalog/perfumes/1/image": return (200, Self.metadata)
            default: return (404, Data())
            }
        }
    }
}
