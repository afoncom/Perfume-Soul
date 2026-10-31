import UIKit
import XCTest
@testable import PerfumeSoul

@MainActor
final class PerfumeImageLoaderTests: XCTestCase {
    func testRepeatedAndConcurrentRequestsReuseDecodedImage() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let loader = PerfumeImageLoader(session: session, cacheDirectory: nil)
        let url = try XCTUnwrap(URL(string: "https://example.com/bottle.png"))
        async let first = loader.image(for: url)
        async let second = loader.image(for: url)
        let (firstImage, secondImage) = try await (first, second)
        let cachedImage = try await loader.image(for: url)
        XCTAssertTrue(firstImage === secondImage)
        XCTAssertTrue(firstImage === cachedImage)
    }

    func testDiskCacheSurvivesNewLoaderAndOfflineSession() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let url = try XCTUnwrap(URL(string: "https://example.com/bottle.png"))
        let first = PerfumeImageLoader(session: session, cacheDirectory: directory)
        let original = try await first.image(for: url)
        session.invalidateAndCancel()
        let second = PerfumeImageLoader(session: session, cacheDirectory: directory)
        let restored = try await second.image(for: url)
        XCTAssertEqual(restored.size, original.size)
    }

    func testResolvedCatalogPhotoSurvivesRestartWithoutMetadataNetwork() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let url = try XCTUnwrap(URL(string: "https://example.com/bottle.png"))
        let perfume = CatalogPerfume(id: 10, name: "One", brand: "Brand", brandID: nil)
        let first = PerfumeImageLoader(session: session, cacheDirectory: directory) { _ in url }
        let originalResult = try await first.image(for: perfume)
        let original = try XCTUnwrap(originalResult)
        session.invalidateAndCancel()
        let second = PerfumeImageLoader(session: session, cacheDirectory: directory) { _ in
            throw URLError(.notConnectedToInternet)
        }
        let restoredResult = try await second.image(for: perfume)
        let restored = try XCTUnwrap(restoredResult)
        XCTAssertEqual(original.size, restored.size)
    }

    func testIDAndCatalogRequestsShareTheDecodedPhoto() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let url = try XCTUnwrap(URL(string: "https://example.com/bottle.png"))
        var resolutions = 0
        let loader = PerfumeImageLoader(session: session, cacheDirectory: nil) { id in
            XCTAssertEqual(id, 10)
            resolutions += 1
            return url
        }
        let first = try await loader.image(for: 10)
        let catalog = CatalogPerfume(id: 10, name: "One", brand: "Brand", brandID: nil)
        let second = try await loader.image(for: catalog)
        let image = try XCTUnwrap(first)
        XCTAssertTrue(image === second)
        XCTAssertTrue(image === loader.cachedImage(for: 10))
        XCTAssertEqual(resolutions, 1)
    }

    func testTemporaryMetadataFailureCanBeRetriedByID() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let url = try XCTUnwrap(URL(string: "https://example.com/bottle.png"))
        var attempts = 0
        let loader = PerfumeImageLoader(session: session, cacheDirectory: nil) { _ in
            attempts += 1
            if attempts == 1 { throw URLError(.timedOut) }
            return url
        }
        do {
            _ = try await loader.image(for: 10)
            XCTFail("Expected the temporary metadata error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .timedOut)
        }
        let recovered = try await loader.image(for: 10)
        XCTAssertNotNil(recovered)
        XCTAssertEqual(attempts, 2)
    }

    func testMissingPhotoIsCachedAcrossIDAndCatalogRequests() async throws {
        var resolutions = 0
        let loader = PerfumeImageLoader(cacheDirectory: nil) { _ in
            resolutions += 1
            return nil
        }
        let first = try await loader.image(for: 10)
        let catalog = CatalogPerfume(id: 10, name: "One", brand: "Brand", brandID: nil)
        let second = try await loader.image(for: catalog)
        XCTAssertNil(first)
        XCTAssertNil(second)
        XCTAssertEqual(resolutions, 1)
    }

    func testMissingAndInvalidImageURLsDoNotBreakCatalogPage() throws {
        let data = Data("""
        {"items":[
            {"id":1,"name":"One","brand":"Brand"},
            {"id":2,"name":"Two","brand":"Brand","imageURL":"relative/path"},
            {"id":3,"name":"Three","brand":"Brand","imageURL":"https://example.com/3.png"}
        ],"hasMore":false}
        """.utf8)
        let page = try JSONDecoder().decode(CatalogPage.self, from: data)
        XCTAssertNil(page.items[0].imageURL)
        XCTAssertNil(page.items[1].imageURL)
        XCTAssertEqual(page.items[2].imageURL?.absoluteString, "https://example.com/3.png")
    }
}

private final class ImageURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        // A complete 1×1 PNG fixture; no network or production image source is needed.
        let data = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1sAAAAASUVORK5CYII=")!
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
