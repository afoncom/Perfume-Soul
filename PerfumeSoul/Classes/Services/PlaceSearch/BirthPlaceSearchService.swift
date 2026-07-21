//
//  BirthPlaceSearchService.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import CoreLocation
import MapKit

struct BirthPlaceSelection: Equatable {
    let displayName: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
}

@MainActor
final class BirthPlaceSearchService: NSObject {
    private let completer = MKLocalSearchCompleter()
    private let geocoder = CLGeocoder()
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

    func resolve(_ completion: MKLocalSearchCompletion) async -> BirthPlaceSelection? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        guard
            let response = try? await search.start(),
            let mapItem = response.mapItems.first
        else {
            return nil
        }

        let coordinate = mapItem.placemark.coordinate
        let timeZoneIdentifier = await resolveTimeZoneIdentifier(for: mapItem.placemark)

        guard let timeZoneIdentifier else {
            return nil
        }

        return BirthPlaceSelection(
            displayName: makeDisplayName(from: completion),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            timeZoneIdentifier: timeZoneIdentifier
        )
    }

    private func resolveTimeZoneIdentifier(for placemark: MKPlacemark) async -> String? {
        if let timeZoneIdentifier = placemark.timeZone?.identifier {
            return timeZoneIdentifier
        }

        let location = CLLocation(
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude
        )

        let placemarks = try? await geocoder.reverseGeocodeLocation(location)
        return placemarks?.first?.timeZone?.identifier
    }

    private func makeDisplayName(from completion: MKLocalSearchCompletion) -> String {
        guard !completion.subtitle.isEmpty else {
            return completion.title
        }

        return "\(completion.title), \(completion.subtitle)"
    }

    private func finishSearch(with results: [MKLocalSearchCompletion]) {
        searchContinuation?.resume(returning: results)
        searchContinuation = nil
    }

    private func failSearch() {
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
    }
}

extension BirthPlaceSearchService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor [weak self] in
            self?.finishSearch(with: completer.results)
        }
    }
    
    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        Task { @MainActor [weak self] in
            self?.failSearch()
        }
    }
}
