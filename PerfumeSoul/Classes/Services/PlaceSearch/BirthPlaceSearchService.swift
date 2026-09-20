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

struct BirthPlaceResolvedPlace {
    let locality: String?
    let subLocality: String?
    let administrativeArea: String?
    let subAdministrativeArea: String?
    let country: String?
    let isPointOfInterest: Bool
    let hasStreetAddress: Bool

    init(
        locality: String? = nil,
        subLocality: String? = nil,
        administrativeArea: String? = nil,
        subAdministrativeArea: String? = nil,
        country: String? = nil,
        isPointOfInterest: Bool = false,
        hasStreetAddress: Bool = false
    ) {
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.country = country
        self.isPointOfInterest = isPointOfInterest
        self.hasStreetAddress = hasStreetAddress
    }
}

enum BirthPlaceResolvedPlaceValidator {
    static func isSupported(_ place: BirthPlaceResolvedPlace) -> Bool {
        guard !place.isPointOfInterest, !place.hasStreetAddress else {
            return false
        }

        return [
            place.locality,
            place.subLocality,
            place.administrativeArea,
            place.subAdministrativeArea,
            place.country
        ].contains { value in
            value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }
}

struct BirthPlaceSuggestion {
    let displayName: String
    let completion: MKLocalSearchCompletion
}

enum BirthPlaceSearchResult {
    case suggestions([BirthPlaceSuggestion])
    case timedOut([BirthPlaceSuggestion])
    case failed
}

enum BirthPlaceSearchError: Error {
    case searchFailed
    case missingDisplayName
    case missingTimeZone
    case unsupportedPlace
}

@MainActor
protocol BirthPlaceSearching {
    func search(_ query: String) async -> BirthPlaceSearchResult
    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSelection
    func clear()
}

@MainActor
final class BirthPlaceSearchService: NSObject {
    private var searchContinuations: [CheckedContinuation<BirthPlaceSearchResult, Never>] = []
    private var searchTimeoutTask: Task<Void, Never>?
    private var searchQuery = ""
    private var activeSearchPass: SearchPass?
    private var latestSearchResults: [MKLocalSearchCompletion] = []

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
            startSearchPass(queryFragment: trimmedQuery)
            startSearchTimeout()
        }
    }
    
    func clear() {
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(with: .suggestions([]))
        searchQuery = ""
        cancelActiveSearchPass()
    }

    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSelection {
        try await withThrowingTaskGroup(of: BirthPlaceSelection.self) { group in
            group.addTask { @MainActor in
                try await self.resolveSelection(suggestion)
            }
            group.addTask {
                try await Task.sleep(for: .seconds(3))
                throw BirthPlaceSearchError.searchFailed
            }

            defer {
                group.cancelAll()
            }

            guard let selection = try await group.next() else {
                throw BirthPlaceSearchError.searchFailed
            }

            return selection
        }
    }

    private func resolveSelection(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSelection {
        let request = MKLocalSearch.Request(completion: suggestion.completion)
        let search = MKLocalSearch(request: request)

        guard
            let response = try? await withTaskCancellationHandler(operation: {
                try await search.start()
            }, onCancel: {
                search.cancel()
            }),
            let mapItem = response.mapItems.first
        else {
            throw BirthPlaceSearchError.searchFailed
        }

        let placemark = mapItem.placemark
        guard BirthPlaceResolvedPlaceValidator.isSupported(
            BirthPlaceResolvedPlace(
                locality: placemark.locality,
                subLocality: placemark.subLocality,
                administrativeArea: placemark.administrativeArea,
                subAdministrativeArea: placemark.subAdministrativeArea,
                country: placemark.country,
                isPointOfInterest: mapItem.pointOfInterestCategory != nil,
                hasStreetAddress: placemark.thoroughfare?.isEmpty == false
                    || placemark.subThoroughfare?.isEmpty == false
            )
        ) else {
            throw BirthPlaceSearchError.unsupportedPlace
        }

        let coordinate = placemark.coordinate
        let timeZoneIdentifier = await resolveTimeZoneIdentifier(for: placemark)

        guard let timeZoneIdentifier else {
            throw BirthPlaceSearchError.missingTimeZone
        }

        let displayName = BirthPlaceNameFormatter.format(
            title: suggestion.completion.title,
            subtitle: suggestion.completion.subtitle
        )

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

        let geocoder = CLGeocoder()
        let placemarks = try? await withTaskCancellationHandler(operation: {
            try await geocoder.reverseGeocodeLocation(location)
        }, onCancel: {
            geocoder.cancelGeocode()
        })
        return placemarks?.first?.timeZone?.identifier
    }

    private func startSearchPass(queryFragment: String) {
        cancelActiveSearchPass()

        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = [.address]
        completer.addressFilter = MKAddressFilter(excluding: [.postalCode])
        activeSearchPass = SearchPass(
            queryFragment: queryFragment,
            completer: completer
        )
        latestSearchResults = []

        completer.queryFragment = queryFragment
    }

    private func cancelActiveSearchPass() {
        activeSearchPass?.completer.cancel()
        activeSearchPass?.completer.delegate = nil
        activeSearchPass = nil
        latestSearchResults = []
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

        if isSearching {
            return
        }

        resumeSearch(with: results)
    }

    private func resumeWithLatestResults() {
        guard !searchContinuations.isEmpty else {
            return
        }

        let suggestions = makeSuggestions(from: latestSearchResults)
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(with: .timedOut(suggestions))
        cancelActiveSearchPass()
    }

    private func resumeSearch(with results: [MKLocalSearchCompletion]) {
        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(
            with: .suggestions(
                makeSuggestions(from: results)
            )
        )
        cancelActiveSearchPass()
    }

    private func makeSuggestions(
        from results: [MKLocalSearchCompletion]
    ) -> [BirthPlaceSuggestion] {
        results.map {
            BirthPlaceSuggestion(
                displayName: makeSuggestionDisplayName(for: $0),
                completion: $0
            )
        }
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
            matchesActiveSearchPass(for: completer)
        else {
            return
        }

        guard latestSearchResults.isEmpty else {
            resumeSearch(with: latestSearchResults)
            return
        }

        searchTimeoutTask?.cancel()
        searchTimeoutTask = nil
        resumeSearchContinuations(with: .failed)
        cancelActiveSearchPass()
    }

    private func matchesActiveSearchPass(for completer: MKLocalSearchCompleter) -> Bool {
        guard let activeSearchPass else {
            return false
        }

        return completer === activeSearchPass.completer
    }
}

extension BirthPlaceSearchService: BirthPlaceSearching { }

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
    let completer: MKLocalSearchCompleter
}

private func makeSuggestionDisplayName(for completion: MKLocalSearchCompletion) -> String {
    return BirthPlaceNameFormatter.format(
        title: completion.title,
        subtitle: completion.subtitle
    )
}
