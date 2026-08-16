//
//  RequestManager.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import Foundation

protocol RequestManager {
    func sendRequest<Response: Decodable>(request: Request) async throws -> Response
}

enum RequestManagerError: Error, Equatable {
    case invalidResponse
    case clientError(statusCode: Int, reason: String?)
    case serverError(statusCode: Int, reason: String?)
}

final class RequestManagerImpl {
    let urlSession: URLSession
    let baseURL: String
    
    init(
        urlSession: URLSession,
        baseURL: String
    ) {
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
}

extension RequestManagerImpl: RequestManager {
    func sendRequest<Response: Decodable>(request: Request) async throws -> Response {
        let urlString = baseURL + request.path

        guard var urlComponents = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }

        urlComponents.queryItems = request.queryItems

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpBody = request.httpBody

        let headers = mergedHeaders(
            defaultHeaders: [
                "Accept-Language": SupportedAppLanguage.currentCode
            ],
            customHeaders: request.headers
        )

        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if request.httpBody != nil, !headers.containsHeader("Content-Type") {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await urlSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RequestManagerError.invalidResponse
        }

        let decoder = JSONDecoder()
        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? decoder.decode(BackendErrorResponse.self, from: data)
            let reason = backendError?.reason

            if (400..<500).contains(httpResponse.statusCode) {
                throw RequestManagerError.clientError(
                    statusCode: httpResponse.statusCode,
                    reason: reason
                )
            }

            throw RequestManagerError.serverError(
                statusCode: httpResponse.statusCode,
                reason: reason
            )
        }

        return try decoder.decode(Response.self, from: data)
    }
}

extension RequestManagerImpl {
    private func mergedHeaders(
        defaultHeaders: [String: String],
        customHeaders: [String: String]
    ) -> [String: String] {
        var headers = defaultHeaders

        customHeaders.forEach { customKey, customValue in
            if let existingKey = headers.keys.first(where: { $0.caseInsensitiveCompare(customKey) == .orderedSame }) {
                headers.removeValue(forKey: existingKey)
            }

            headers[customKey] = customValue
        }

        return headers
    }
}

extension Dictionary where Key == String, Value == String {
    fileprivate func containsHeader(_ header: String) -> Bool {
        keys.contains { $0.caseInsensitiveCompare(header) == .orderedSame }
    }
}

private struct BackendErrorResponse: Decodable {
    let reason: String?
}
