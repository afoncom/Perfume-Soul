import Foundation
import NIOCore
import Testing
import Vapor
import VaporTesting
@testable import PerfumeSoulBackend

struct FragellaImageTests {
    @Test("Temporary HTTP provider failures are thrown", arguments: [
        HTTPResponseStatus.tooManyRequests, HTTPResponseStatus.serviceUnavailable
    ])
    func httpProviderFailureIsThrown(status: HTTPResponseStatus) async throws {
        try await withApp { app in
            let client = FragellaFailureClient(
                eventLoop: app.eventLoopGroup.next(),
                result: .success(ClientResponse(status: status))
            )
            await #expect(throws: Abort.self) {
                try await FragellaImageLookup.lookup(
                    client: client, apiKey: "test-key", brand: "Dior", name: "Sauvage", concentration: nil
                )
            }
        }
    }

    @Test("Provider timeouts are thrown instead of returning a missing photo")
    func providerTimeoutIsThrown() async throws {
        try await withApp { app in
            let client = FragellaFailureClient(
                eventLoop: app.eventLoopGroup.next(),
                result: .failure(URLError(.timedOut))
            )
            await #expect(throws: URLError.self) {
                try await FragellaImageLookup.lookup(
                    client: client, apiKey: "test-key", brand: "Dior", name: "Sauvage", concentration: nil
                )
            }
        }
    }

    @Test("A successful empty provider response returns nil")
    func successfulLookupWithoutPhotoReturnsNil() async throws {
        try await withApp { app in
            let client = FragellaFailureClient(
                eventLoop: app.eventLoopGroup.next(),
                result: .success(ClientResponse(
                    status: .ok, headers: ["Content-Type": "application/json"], body: ByteBuffer(string: "[]")
                ))
            )
            let imageURL = try await FragellaImageLookup.lookup(
                client: client, apiKey: "test-key", brand: "Dior", name: "Sauvage", concentration: nil
            )
            #expect(imageURL == nil)
        }
    }

    @Test("Selects only an exact fragrance from the same brand")
    func exactMatch() throws {
        let response = """
        [
            {"Name":"Sauvage Elixir","Brand":"Dior","Image URL":"https://cdn.fragella.com/images/elixir.jpg"},
            {"Name":"Dior Sauvage","Brand":"Dior","Image URL":"https://cdn.fragella.com/images/sauvage.jpg"},
            {"Name":"Sauvage","Brand":"Other","Image URL":"https://cdn.fragella.com/images/other.jpg"}
        ]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage")
            == "https://cdn.fragella.com/images/sauvage.jpg")
        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage Parfum") == nil)
    }

    @Test("Rejects image URLs outside Fragella CDN")
    func rejectsRetailerImage() throws {
        let response = """
        [{"Name":"Sauvage","Brand":"Dior","Image URL":"https://shop.example.com/sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage") == nil)
    }

    @Test("Rejects a different concentration")
    func rejectsDifferentConcentration() throws {
        let response = """
        [{"Name":"Sauvage","Brand":"Dior","OilType":"Eau de Toilette","Image URL":"https://cdn.fragella.com/images/sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(
            in: matches, brand: "Dior", name: "Sauvage", concentration: "Eau de Parfum"
        ) == nil)
    }

    @Test("Matches Dior with Fragella's Christian Dior brand name")
    func matchesDiorAlias() throws {
        let response = """
        [{"Name":"Dior Sauvage","Brand":"Christian Dior","OilType":"Eau de Toilette","Image URL":"https://cdn.fragella.com/images/dior-sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(
            in: matches, brand: "Dior", name: "Sauvage", concentration: "eau de toilette"
        ) == "https://cdn.fragella.com/images/dior-sauvage.jpg")
    }
}

private struct FragellaFailureClient: Client {
    let eventLoop: any EventLoop
    let result: Result<ClientResponse, any Error>

    func delegating(to eventLoop: any EventLoop) -> any Client {
        FragellaFailureClient(eventLoop: eventLoop, result: result)
    }

    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        switch result {
        case .success(let response): return eventLoop.makeSucceededFuture(response)
        case .failure(let error): return eventLoop.makeFailedFuture(error)
        }
    }
}
