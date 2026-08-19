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

struct BirthPlaceSuggestion: Identifiable {
    let id = UUID()
    let displayName: String
    let completion: MKLocalSearchCompletion
    let isQueryFallback: Bool
}

enum BirthPlaceSearchError: Error {
    case searchFailed
    case missingDisplayName
    case missingTimeZone
}

enum BirthPlaceSearchOutcome: Equatable {
    case wait
    case escalate
    case resume
}

enum BirthPlaceSearchPassResolver {
    static func outcome(
        isEmpty: Bool,
        isSearching: Bool,
        isQueryFallback: Bool
    ) -> BirthPlaceSearchOutcome {
        if isSearching {
            return .wait
        }

        if isEmpty, !isQueryFallback {
            return .escalate
        }

        return .resume
    }
}

@MainActor
final class BirthPlaceSearchService: NSObject {
    private let addressCompleter = MKLocalSearchCompleter()
    private let fallbackCompleter = MKLocalSearchCompleter()
    private let geocoder = CLGeocoder()
    private var searchContinuation: CheckedContinuation<[BirthPlaceSuggestion], Never>?
    private var searchQuery = ""
    private var activeSearchPass: SearchPass?

    override init() {
        super.init()
        addressCompleter.delegate = self
        addressCompleter.resultTypes = [.address]
        fallbackCompleter.delegate = self
        fallbackCompleter.resultTypes = [.query]
    }

    func search(_ query: String) async -> [BirthPlaceSuggestion] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedQuery.count >= 2 else {
            clear()
            return []
        }
        
        return await withCheckedContinuation { continuation in
            searchContinuation?.resume(returning: [])
            searchContinuation = continuation
            searchQuery = trimmedQuery
            startSearchPass(
                queryFragment: trimmedQuery,
                isQueryFallback: false
            )
        }
    }
    
    func clear() {
        addressCompleter.queryFragment = ""
        fallbackCompleter.queryFragment = ""
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
        searchQuery = ""
        activeSearchPass = nil
    }

    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSelection {
        let request = MKLocalSearch.Request(completion: suggestion.completion)
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

        let displayName = try makeDisplayName(for: suggestion, mapItem: mapItem)

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
        for suggestion: BirthPlaceSuggestion,
        mapItem: MKMapItem
    ) throws -> String {
        guard suggestion.isQueryFallback else {
            return BirthPlaceNameFormatter.format(
                title: suggestion.completion.title,
                subtitle: suggestion.completion.subtitle
            )
        }

        let placemark = mapItem.placemark
        let resolvedName = placemark.locality ?? placemark.administrativeArea
        guard
            let resolvedName,
            BirthPlaceNameFormatter.place(resolvedName, matchesComponentIn: suggestion.completion.title)
        else {
            throw BirthPlaceSearchError.missingDisplayName
        }

        return BirthPlaceNameFormatter.format(
            title: resolvedName,
            subtitle: [placemark.administrativeArea, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
        )
    }

    private func startSearchPass(
        queryFragment: String,
        isQueryFallback: Bool
    ) {
        activeSearchPass = SearchPass(
            queryFragment: queryFragment,
            isQueryFallback: isQueryFallback
        )

        if isQueryFallback {
            fallbackCompleter.queryFragment = queryFragment
        } else {
            addressCompleter.queryFragment = queryFragment
        }
    }

    private func finishSearch(
        with results: [MKLocalSearchCompletion],
        from completer: MKLocalSearchCompleter,
        queryFragment: String,
        isSearching: Bool
    ) {
        guard
            searchContinuation != nil,
            let currentSearchPass = activeSearchPass,
            currentSearchPass.queryFragment == queryFragment,
            matchesActiveSearchPass(for: completer)
        else {
            return
        }

        switch BirthPlaceSearchPassResolver.outcome(
            isEmpty: results.isEmpty,
            isSearching: isSearching,
            isQueryFallback: currentSearchPass.isQueryFallback
        ) {
        case .wait:
            return
        case .escalate:
            startSearchPass(queryFragment: searchQuery, isQueryFallback: true)
            return
        case .resume:
            searchContinuation?.resume(
                returning: results.map {
                    BirthPlaceSuggestion(
                        displayName: makeSuggestionDisplayName(
                            for: $0,
                            isQueryFallback: currentSearchPass.isQueryFallback
                        ),
                        completion: $0,
                        isQueryFallback: currentSearchPass.isQueryFallback
                    )
                }
            )
            searchContinuation = nil
        }
    }

    private func failSearch(from completer: MKLocalSearchCompleter) {
        guard
            searchContinuation != nil,
            matchesActiveSearchPass(for: completer),
            let currentSearchPass = activeSearchPass
        else {
            return
        }

        if !currentSearchPass.isQueryFallback {
            startSearchPass(queryFragment: searchQuery, isQueryFallback: true)
            return
        }

        searchContinuation?.resume(returning: [])
        searchContinuation = nil
    }

    private func matchesActiveSearchPass(for completer: MKLocalSearchCompleter) -> Bool {
        guard let activeSearchPass else {
            return false
        }

        if completer === addressCompleter {
            return !activeSearchPass.isQueryFallback
        }

        if completer === fallbackCompleter {
            return activeSearchPass.isQueryFallback
        }

        return false
    }
}

extension BirthPlaceSearchService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let queryFragment = completer.queryFragment
        let results = completer.results
        let isSearching = completer.isSearching
        Task { @MainActor [weak self] in
            self?.finishSearch(
                with: results,
                from: completer,
                queryFragment: queryFragment,
                isSearching: isSearching
            )
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        Task { @MainActor [weak self] in
            self?.failSearch(from: completer)
        }
    }
}

private struct SearchPass {
    let queryFragment: String
    let isQueryFallback: Bool
}

private func makeSuggestionDisplayName(
    for completion: MKLocalSearchCompletion,
    isQueryFallback: Bool
) -> String {
    guard !isQueryFallback else {
        return completion.title
    }

    return BirthPlaceNameFormatter.format(
        title: completion.title,
        subtitle: completion.subtitle
    )
}
