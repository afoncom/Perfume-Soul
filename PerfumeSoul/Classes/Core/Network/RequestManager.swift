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
        let urlString = baseURL + request.path
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }

        urlComponents.queryItems = request.queryItems
        
        guard let url = urlComponents.url else { throw URLError(.badURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        
        let (data, responce) = try await urlSession.data(for: urlRequest)
        print(data)
        print(responce)
    }
}
