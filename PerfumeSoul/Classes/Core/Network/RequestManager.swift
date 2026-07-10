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
        
        guard let url = urlComponents.url else { throw URLError(.badURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpBody = request.httpBody

        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if request.httpBody != nil, request.headers["Content-Type"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, responce) = try await urlSession.data(for: urlRequest)
        
        print(responce)
        
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
