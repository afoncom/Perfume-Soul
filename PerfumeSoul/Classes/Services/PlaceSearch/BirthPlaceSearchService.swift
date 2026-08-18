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

enum BirthPlaceSearchError: Error {
    case searchFailed
    case missingDisplayName
    case missingTimeZone
}

@MainActor
final class BirthPlaceSearchService: NSObject {
    private let completer = MKLocalSearchCompleter()
    private let geocoder = CLGeocoder()
    private var searchContinuation: CheckedContinuation<[MKLocalSearchCompletion], Never>?
    private var searchQuery = ""
    private var isRunningQueryFallback = false

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address]
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
            searchQuery = trimmedQuery
            isRunningQueryFallback = false
            completer.resultTypes = [.address]
            completer.queryFragment = trimmedQuery
        }
    }
    
    func clear() {
        completer.queryFragment = ""
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
        searchQuery = ""
        isRunningQueryFallback = false
    }

    func resolve(_ completion: MKLocalSearchCompletion) async throws -> BirthPlaceSelection {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        guard
            let response = try? await search.start(),
            let mapItem = response.mapItems.first
        else {
            throw BirthPlaceSearchError.searchFailed
        }

        let coordinate = mapItem.placemark.coordinate
        let timeZoneIdentifier = await resolveTimeZoneIdentifier(for: mapItem.placemark)

        guard let timeZoneIdentifier else {
            throw BirthPlaceSearchError.missingTimeZone
        }

        let displayName = try makeDisplayName(for: completion, mapItem: mapItem)

        guard !displayName.isEmpty else {
            throw BirthPlaceSearchError.missingDisplayName
        }

        return BirthPlaceSelection(
            displayName: displayName,
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

    private func makeDisplayName(
        for completion: MKLocalSearchCompletion,
        mapItem: MKMapItem
    ) throws -> String {
        guard isRunningQueryFallback else {
            return BirthPlaceNameFormatter.format(
                title: completion.title,
                subtitle: completion.subtitle
            )
        }

        let placemark = mapItem.placemark
        guard placemark.locality != nil || placemark.administrativeArea != nil else {
            throw BirthPlaceSearchError.missingDisplayName
        }

        return BirthPlaceNameFormatter.format(
            title: placemark.locality ?? placemark.administrativeArea ?? "",
            subtitle: [placemark.administrativeArea, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
        )
    }

    private func finishSearch(with results: [MKLocalSearchCompletion]) {
        guard searchContinuation != nil else {
            return
        }

        if results.isEmpty, !isRunningQueryFallback {
            isRunningQueryFallback = true
            completer.resultTypes = [.query]
            completer.queryFragment = ""
            completer.queryFragment = searchQuery
            return
        }

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
