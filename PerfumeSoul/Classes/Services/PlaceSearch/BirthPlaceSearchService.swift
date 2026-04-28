//
//  BirthPlaceSearchService.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import MapKit

@MainActor
final class BirthPlaceSearchService: NSObject {
    private let completer = MKLocalSearchCompleter()
    private var searchContinuation: CheckedContinuation<[MKLocalSearchCompletion], Never>?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .query]
    }
    
    func search(_ query: String) async -> [MKLocalSearchCompletion] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedQuery.count >= 2 else {
            clear()
            return []
        }
        
        return await withCheckedContinuation { continuation in
            searchContinuation?.resume(returning: [])
            searchContinuation = continuation
            completer.queryFragment = trimmedQuery
        }
    }
    
    func clear() {
        completer.queryFragment = ""
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
    }
}

extension BirthPlaceSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchContinuation?.resume(returning: completer.results)
        searchContinuation = nil
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
    }
}
