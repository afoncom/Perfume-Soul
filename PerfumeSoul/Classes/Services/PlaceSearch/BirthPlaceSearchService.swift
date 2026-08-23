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
    var id: String { "\(completion.title)|\(completion.subtitle)" }
    let displayName: String
    let completion: MKLocalSearchCompletion
    let isQueryFallback: Bool
}

enum BirthPlaceSearchResult {
    case suggestions([BirthPlaceSuggestion])
    case failed
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
    private let geocoder = CLGeocoder()
    private var searchContinuations: [CheckedContinuation<BirthPlaceSearchResult, Never>] = []
    private var searchTimeoutTask: Task<Void, Never>?
    private var searchQuery = ""
    private var activeSearchPass: SearchPass?
    private var latestSearchResults: [MKLocalSearchCompletion] = []
    private var latestSearchPass: SearchPass?

    override init() {
        super.init()
    }

    func search(_ query: String) async -> BirthPlaceSearchResult {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedQuery.count >= 2 else {
            clear()
            return .suggestions([])
        }

        guard trimmedQuery != searchQuery || searchContinuations.isEmpty else {
            return await withCheckedContinuation { continuation in
                searchContinuations.append(continuation)
            }
        }
        
        return await withCheckedContinuation { continuation in
            searchTimeoutTask?.cancel()
            resumeSearchContinuations(with: .suggestions([]))
            searchContinuations = [continuation]
            searchQuery = trimmedQuery
            latestSearchResults = []
            latestSearchPass = nil
            startSearchPass(
                queryFragment: trimmedQuery,
                isQueryFallback: false
            )
            startSearchTimeout()
        }
    }
    
    func clear() {
        activeSearchPass?.completer.delegate = nil
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(with: .suggestions([]))
        searchQuery = ""
        activeSearchPass = nil
        latestSearchResults = []
        latestSearchPass = nil
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
        guard let resolvedName = placemark.locality ?? placemark.administrativeArea else {
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
        activeSearchPass?.completer.delegate = nil

        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = isQueryFallback ? [.query] : [.address]
        activeSearchPass = SearchPass(
            queryFragment: queryFragment,
            isQueryFallback: isQueryFallback,
            completer: completer
        )
        latestSearchResults = []
        latestSearchPass = activeSearchPass

        completer.queryFragment = queryFragment
    }

    private func startSearchTimeout() {
        searchTimeoutTask?.cancel()
        searchTimeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else {
                return
            }

            self?.resumeWithLatestResults()
        }
    }

    private func finishSearch(
        with results: [MKLocalSearchCompletion],
        from completer: MKLocalSearchCompleter,
        queryFragment: String,
        isSearching: Bool
    ) {
        guard
            !searchContinuations.isEmpty,
            let currentSearchPass = activeSearchPass,
            currentSearchPass.queryFragment == queryFragment,
            matchesActiveSearchPass(for: completer)
        else {
            return
        }
        latestSearchResults = results
        latestSearchPass = currentSearchPass

        switch BirthPlaceSearchPassResolver.outcome(
            isEmpty: results.isEmpty,
            isSearching: isSearching,
            isQueryFallback: currentSearchPass.isQueryFallback
        ) {
        case .wait:
            return
        case .escalate:
            startSearchPass(queryFragment: searchQuery, isQueryFallback: true)
            startSearchTimeout()
            return
        case .resume:
            resumeSearch(with: results, isQueryFallback: currentSearchPass.isQueryFallback)
        }
    }

    private func resumeWithLatestResults() {
        guard !searchContinuations.isEmpty else {
            return
        }

        resumeSearch(
            with: latestSearchResults,
            isQueryFallback: latestSearchPass?.isQueryFallback ?? false
        )
    }

    private func resumeSearch(
        with results: [MKLocalSearchCompletion],
        isQueryFallback: Bool
    ) {
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(
            with: .suggestions(results.map {
                BirthPlaceSuggestion(
                    displayName: makeSuggestionDisplayName(
                        for: $0,
                        isQueryFallback: isQueryFallback
                    ),
                    completion: $0,
                    isQueryFallback: isQueryFallback
                )
            })
        )
        activeSearchPass = nil
        latestSearchResults = []
        latestSearchPass = nil
    }

    private func resumeSearchContinuations(with result: BirthPlaceSearchResult) {
        let continuations = searchContinuations
        searchContinuations = []
        continuations.forEach {
            $0.resume(returning: result)
        }
    }

    private func failSearch(from completer: MKLocalSearchCompleter) {
        guard
            !searchContinuations.isEmpty,
            matchesActiveSearchPass(for: completer),
            let currentSearchPass = activeSearchPass
        else {
            return
        }

        if !currentSearchPass.isQueryFallback {
            startSearchPass(queryFragment: searchQuery, isQueryFallback: true)
            startSearchTimeout()
            return
        }

        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(with: .failed)
        activeSearchPass = nil
        latestSearchResults = []
        latestSearchPass = nil
    }

    private func matchesActiveSearchPass(for completer: MKLocalSearchCompleter) -> Bool {
        guard let activeSearchPass else {
            return false
        }

        return completer === activeSearchPass.completer
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
    let completer: MKLocalSearchCompleter
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
