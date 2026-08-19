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

@MainActor
final class BirthPlaceSearchService: NSObject {
    private let completer = MKLocalSearchCompleter()
    private let geocoder = CLGeocoder()
    private var searchContinuation: CheckedContinuation<[BirthPlaceSuggestion], Never>?
    private var searchQuery = ""
    private var activeSearchPass: SearchPass?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address]
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
                resultTypes: [.address],
                isQueryFallback: false
            )
        }
    }
    
    func clear() {
        completer.queryFragment = ""
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
            isSamePlaceComponent(resolvedName, suggestion.completion.title)
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

    private func isSamePlaceComponent(_ lhs: String, _ rhs: String) -> Bool {
        let normalizedLHS = normalizePlaceComponent(lhs)
        let rhsComponents = rhs
            .split(separator: ",")
            .map(String.init)
            .map(normalizePlaceComponent)

        return rhsComponents.contains(normalizedLHS)
    }

    private func normalizePlaceComponent(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }

    private func startSearchPass(
        queryFragment: String,
        resultTypes: MKLocalSearchCompleter.ResultType,
        isQueryFallback: Bool
    ) {
        activeSearchPass = SearchPass(
            queryFragment: queryFragment,
            isQueryFallback: isQueryFallback
        )
        completer.resultTypes = resultTypes
        completer.queryFragment = queryFragment
    }

    private func finishSearch(
        with results: [MKLocalSearchCompletion],
        queryFragment: String
    ) {
        guard
            searchContinuation != nil,
            let currentSearchPass = activeSearchPass,
            currentSearchPass.queryFragment == queryFragment
        else {
            return
        }

        if results.isEmpty, !currentSearchPass.isQueryFallback {
            completer.queryFragment = ""
            activeSearchPass = nil
            let fallbackQuery = searchQuery
            Task { @MainActor [weak self] in
                guard
                    let self,
                    self.searchContinuation != nil,
                    self.activeSearchPass == nil,
                    self.searchQuery == fallbackQuery
                else {
                    return
                }

                self.startSearchPass(
                    queryFragment: fallbackQuery,
                    resultTypes: [.query],
                    isQueryFallback: true
                )
            }
            return
        }

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

    private func failSearch() {
        searchContinuation?.resume(returning: [])
        searchContinuation = nil
    }
}

extension BirthPlaceSearchService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let queryFragment = completer.queryFragment
        Task { @MainActor [weak self] in
            self?.finishSearch(
                with: completer.results,
                queryFragment: queryFragment
            )
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        Task { @MainActor [weak self] in
            self?.failSearch()
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
