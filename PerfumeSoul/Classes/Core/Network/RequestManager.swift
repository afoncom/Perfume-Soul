//
//  RequestManager.swift
//  PerfumeSoul
//
//  Created by afon.com on 25.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import Foundation


protocol RequestManager {
    func sendRequest(request: Request) async throws
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
    func sendRequest(request: Request) async throws {
//        let url = URL(string: baseURL + request.path)
//        guard let url else { throw URLError(.badURL) }

        //
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        urlComponents.path += request.path
        if !request.queryItems.isEmpty {
            urlComponents.queryItems = request.queryItems
        }

        guard let url = urlComponents.url else { throw URLError(.badURL) }
        //
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        
        let (data, responce) = try await urlSession.data(for: urlRequest)
        print(data)
        print(responce)
    }
}
