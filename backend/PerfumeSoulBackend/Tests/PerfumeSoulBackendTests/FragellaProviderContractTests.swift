import Foundation
import NIOCore
import Testing
import Vapor
import VaporTesting
@testable import PerfumeSoulBackend

struct FragellaProviderContractTests {
    @Test("Fragella lookup authenticates the request and returns the matching CDN image")
    func successfulLookup() async throws {
        try await withApp { app in
            let client = FragellaClientStub(eventLoop: app.eventLoopGroup.next()) { request in
                #expect(request.method == .GET)
                #expect(request.url.host == "api.fragella.com")
                #expect(request.url.path == "/api/v1/fragrances")
                #expect(request.headers.first(name: "x-api-key") == "test-key")
                let parameters = URLComponents(string: request.url.string)?.queryItems
                let search = parameters?.first { $0.name == "search" }?.value
                let limit = parameters?.first { $0.name == "limit" }?.value
                #expect(search == "Sauvage")
                #expect(limit == "10")
                return Self.response(body: Self.matchingPhoto)
            }

            let imageURL = try await lookup(client: client)

            #expect(imageURL == Self.expectedURL)
        }
    }

    @Test("A successful empty provider result is cached as a missing photo")
    func missingPhoto() async throws {
        try await withApp { app in
            let client = FragellaClientStub(eventLoop: app.eventLoopGroup.next()) { _ in
                Self.response(body: "[]")
            }
            let cache = CatalogImageCache()
            let first = try await cache.imageURL(for: 1) { try await lookup(client: client) }
            let second = try await cache.imageURL(for: 1) { Self.expectedURL }

            #expect(first == nil)
            #expect(second == nil)
        }
    }

    @Test("Provider HTTP failures throw and do not poison the missing-photo cache", arguments: [
        HTTPResponseStatus.unauthorized,
        HTTPResponseStatus.tooManyRequests,
        HTTPResponseStatus.serviceUnavailable
    ])
    func httpFailureCanBeRetried(status: HTTPResponseStatus) async throws {
        try await withApp { app in
            let failing = FragellaClientStub(eventLoop: app.eventLoopGroup.next()) { _ in
                Self.response(status: status, body: "{}")
            }
            let cache = CatalogImageCache()
            do {
                _ = try await cache.imageURL(for: 1) { try await lookup(client: failing) }
                Issue.record("Expected an HTTP provider failure to throw, not return nil")
            } catch let error as Abort {
                #expect(error.status == .badGateway)
            }

            try await expectRecovery(cache: cache, eventLoop: app.eventLoopGroup.next())
        }
    }

    @Test("A transport timeout throws and the next request can recover")
    func transportFailureCanBeRetried() async throws {
        try await withApp { app in
            let client = FragellaClientStub(eventLoop: app.eventLoopGroup.next()) { _ in
                throw URLError(.timedOut)
            }
            let cache = CatalogImageCache()
            await #expect(throws: URLError.self) {
                try await cache.imageURL(for: 1) { try await lookup(client: client) }
            }

            try await expectRecovery(cache: cache, eventLoop: app.eventLoopGroup.next())
        }
    }

    @Test("Malformed provider JSON throws and is not cached as a missing photo")
    func invalidJSONCanBeRetried() async throws {
        try await withApp { app in
            let client = FragellaClientStub(eventLoop: app.eventLoopGroup.next()) { _ in
                Self.response(body: "not JSON")
            }
            let cache = CatalogImageCache()
            await #expect(throws: (any Error).self) {
                try await cache.imageURL(for: 1) { try await lookup(client: client) }
            }

            try await expectRecovery(cache: cache, eventLoop: app.eventLoopGroup.next())
        }
    }

    private func expectRecovery(cache: CatalogImageCache, eventLoop: any EventLoop) async throws {
        let recovered = FragellaClientStub(eventLoop: eventLoop) { _ in
            Self.response(body: Self.matchingPhoto)
        }
        let imageURL = try await cache.imageURL(for: 1) { try await lookup(client: recovered) }
        #expect(imageURL == Self.expectedURL)
    }

    private func lookup(client: any Client) async throws -> String? {
        try await FragellaImageLookup.lookup(
            client: client,
            apiKey: "test-key",
            brand: "Dior",
            name: "Sauvage",
            concentration: "Eau de Toilette"
        )
    }

    private static let expectedURL = "https://cdn.fragella.com/images/dior-sauvage.jpg"
    private static let matchingPhoto = """
    [{"Name":"Dior Sauvage","Brand":"Christian Dior","OilType":"Eau de Toilette","Image URL":"https://cdn.fragella.com/images/dior-sauvage.jpg"}]
    """

    private static func response(status: HTTPResponseStatus = .ok, body: String) -> ClientResponse {
        ClientResponse(
            status: status,
            headers: ["Content-Type": "application/json"],
            body: ByteBuffer(string: body)
        )
    }
}

private struct FragellaClientStub: Client {
    let eventLoop: any EventLoop
    let respond: @Sendable (ClientRequest) throws -> ClientResponse

    func delegating(to eventLoop: any EventLoop) -> any Client {
        FragellaClientStub(eventLoop: eventLoop, respond: respond)
    }

    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        do {
            return eventLoop.makeSucceededFuture(try respond(request))
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
}
