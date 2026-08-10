//
//  RequestManagerTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 25.07.2026.
//

import Foundation
import XCTest
@testable import PerfumeSoul

final class RequestManagerTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.requestHandler = nil
    }

    func testSendRequestThrowsClientErrorForHTTP400() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )
            )
            let data = Data(#"{"error":true,"reason":"Invalid local time"}"#.utf8)
            return (response, data)
        }

        let requestManager = RequestManagerImpl(
            urlSession: makeURLSession(),
            baseURL: "https://example.com"
        )

        do {
            let _: TestResponse = try await requestManager.sendRequest(request: TestRequest())
            XCTFail("Expected client error")
        } catch RequestManagerError.clientError(let statusCode, let reason) {
            XCTAssertEqual(statusCode, 400)
            XCTAssertEqual(reason, "Invalid local time")
        }
    }

    func testSendRequestDecodesSuccessfulResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
            )
            let data = Data(#"{"value":"ok"}"#.utf8)
            return (response, data)
        }

        let requestManager = RequestManagerImpl(
            urlSession: makeURLSession(),
            baseURL: "https://example.com"
        )

        let response: TestResponse = try await requestManager.sendRequest(request: TestRequest())

        XCTAssertEqual(response.value, "ok")
    }

    private func makeURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private struct TestRequest: Request {
    let path = "/test"
    let httpMethod: HTTPMethod = .get
}

private struct TestResponse: Decodable {
    let value: String
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            XCTFail("Request handler is not set")
            return
        }

        do {
            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
    }
}
