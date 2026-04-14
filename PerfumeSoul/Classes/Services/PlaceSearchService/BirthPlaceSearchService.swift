//
//  BirthPlaceSearchService.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Combine
import MapKit

final class BirthPlaceSearchService: NSObject, ObservableObject {
    @Published private(set) var completions: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedQuery.count >= 2 else {
            clear()
            return
        }
        
        completer.queryFragment = trimmedQuery
    }
    
    func clear() {
        completions = []
    }
    
    func formattedTitle(for completion: MKLocalSearchCompletion) -> String {
        guard !completion.subtitle.isEmpty else { return completion.title }
        return "\(completion.title), \(completion.subtitle)"
    }
}

extension BirthPlaceSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        completions = []
    }
}
