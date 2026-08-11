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

        let defaultHeaders = [
            "Accept-Language": SupportedAppLanguage.currentCode
        ]

        defaultHeaders
            .merging(request.headers) { _, custom in custom }
            .forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }

        if request.httpBody != nil, request.headers["Content-Type"] == nil {
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

private struct BackendErrorResponse: Decodable {
    let reason: String?
}
