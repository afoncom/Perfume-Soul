//
//  CalculationPresenterTests.swift
//  PerfumeSoulTests
//
//  Created by afon.com on 25.08.2026.
//

import MapKit
import XCTest
@testable import PerfumeSoul

final class CalculationPresenterTests: XCTestCase {
    @MainActor
    func testFailedBirthPlaceSearchClearsActiveQueryAndEnablesRetry() async {
        let viewModel = CalculationViewModel()
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.searchResult = .failed
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        await presenter.birthPlaceDidChange("Paris")

        XCTAssertEqual(viewModel.activeBirthPlaceSearchQuery, "")
        XCTAssertEqual(viewModel.birthPlaceErrorMessage, L10n.Calculation.birthPlaceSearchError)
        XCTAssertTrue(viewModel.canRetryBirthPlaceSearch)
        XCTAssertTrue(viewModel.birthPlaceSuggestions.isEmpty)
        XCTAssertFalse(viewModel.isSearchingBirthPlace)
    }

    @MainActor
    func testNonEmptyTimedOutBirthPlaceSearchKeepsSuggestionsWithoutRetry() async {
        let viewModel = CalculationViewModel()
        let suggestion = makeSuggestion(displayName: "Paris, France")
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.searchResult = .timedOut([suggestion])
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        await presenter.birthPlaceDidChange("Paris")

        XCTAssertEqual(viewModel.activeBirthPlaceSearchQuery, "Paris")
        XCTAssertNil(viewModel.birthPlaceErrorMessage)
        XCTAssertFalse(viewModel.canRetryBirthPlaceSearch)
        XCTAssertEqual(viewModel.birthPlaceSuggestions.map(\.displayName), ["Paris, France"])
        XCTAssertFalse(viewModel.isSearchingBirthPlace)
    }

    @MainActor
    func testResolveFailureRestoresPreviousSuggestions() async {
        let viewModel = CalculationViewModel()
        let suggestion = makeSuggestion(displayName: "Paris, France")
        viewModel.birthPlaceSuggestions = [suggestion]
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.resolveError = BirthPlaceSearchError.searchFailed
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        await presenter.birthPlaceSuggestionTapped(suggestion)

        XCTAssertEqual(viewModel.birthPlaceSuggestions.map(\.displayName), ["Paris, France"])
        XCTAssertEqual(viewModel.birthPlaceErrorMessage, L10n.Calculation.birthPlaceSelectionError)
        XCTAssertFalse(viewModel.canRetryBirthPlaceSearch)
        XCTAssertFalse(viewModel.isSearchingBirthPlace)
    }

    @MainActor
    func testSuccessfulResolveClearsActiveBirthPlaceSearchQuery() async {
        let viewModel = CalculationViewModel()
        let suggestion = makeSuggestion(displayName: "Paris, France")
        viewModel.activeBirthPlaceSearchQuery = "Par"
        viewModel.birthPlaceSuggestions = [suggestion]
        let selection = BirthPlaceSelection(
            displayName: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522,
            timeZoneIdentifier: "Europe/Paris"
        )
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.resolveSelection = selection
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        await presenter.birthPlaceSuggestionTapped(suggestion)

        XCTAssertEqual(viewModel.birthPlace, "Paris, France")
        XCTAssertEqual(viewModel.selectedBirthPlace, selection)
        XCTAssertEqual(viewModel.activeBirthPlaceSearchQuery, "")
        XCTAssertTrue(viewModel.birthPlaceSuggestions.isEmpty)
        XCTAssertTrue(birthPlaceSearch.didClear)
    }

    @MainActor
    func testResolveResultDoesNotOverwriteNewerBirthPlaceQuery() async {
        let viewModel = CalculationViewModel()
        let parisSuggestion = makeSuggestion(displayName: "Paris, France")
        let berlinSuggestion = makeSuggestion(displayName: "Berlin, Germany")
        viewModel.birthPlace = "Par"
        viewModel.activeBirthPlaceSearchQuery = "Par"
        viewModel.birthPlaceSuggestions = [parisSuggestion]
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.resolveSelection = BirthPlaceSelection(
            displayName: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522,
            timeZoneIdentifier: "Europe/Paris"
        )
        birthPlaceSearch.beforeResolveReturns = {
            viewModel.birthPlace = "Berlin"
            viewModel.activeBirthPlaceSearchQuery = "Berlin"
            viewModel.birthPlaceSuggestions = [berlinSuggestion]
            viewModel.isSearchingBirthPlace = false
        }
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        let isStillCurrent = await presenter.birthPlaceSuggestionTapped(parisSuggestion)

        XCTAssertFalse(isStillCurrent)
        XCTAssertEqual(viewModel.birthPlace, "Berlin")
        XCTAssertNil(viewModel.selectedBirthPlace)
        XCTAssertEqual(viewModel.activeBirthPlaceSearchQuery, "Berlin")
        XCTAssertEqual(viewModel.birthPlaceSuggestions.map(\.displayName), ["Berlin, Germany"])
        XCTAssertFalse(viewModel.isSearchingBirthPlace)
        XCTAssertFalse(birthPlaceSearch.didClear)
    }

    @MainActor
    func testResolveErrorDoesNotRestorePreviousSuggestionsForNewerBirthPlaceQuery() async {
        let viewModel = CalculationViewModel()
        let parisSuggestion = makeSuggestion(displayName: "Paris, France")
        let berlinSuggestion = makeSuggestion(displayName: "Berlin, Germany")
        viewModel.birthPlace = "Par"
        viewModel.activeBirthPlaceSearchQuery = "Par"
        viewModel.birthPlaceSuggestions = [parisSuggestion]
        let birthPlaceSearch = BirthPlaceSearchMock()
        birthPlaceSearch.resolveError = BirthPlaceSearchError.missingTimeZone
        birthPlaceSearch.beforeResolveReturns = {
            viewModel.birthPlace = "Berlin"
            viewModel.activeBirthPlaceSearchQuery = "Berlin"
            viewModel.birthPlaceSuggestions = [berlinSuggestion]
            viewModel.isSearchingBirthPlace = false
        }
        let presenter = makePresenter(
            viewModel: viewModel,
            birthPlaceSearch: birthPlaceSearch
        )

        let isStillCurrent = await presenter.birthPlaceSuggestionTapped(parisSuggestion)

        XCTAssertFalse(isStillCurrent)
        XCTAssertEqual(viewModel.birthPlace, "Berlin")
        XCTAssertNil(viewModel.selectedBirthPlace)
        XCTAssertEqual(viewModel.activeBirthPlaceSearchQuery, "Berlin")
        XCTAssertEqual(viewModel.birthPlaceSuggestions.map(\.displayName), ["Berlin, Germany"])
        XCTAssertNil(viewModel.birthPlaceErrorMessage)
        XCTAssertFalse(viewModel.isSearchingBirthPlace)
    }

    @MainActor
    private func makePresenter(
        viewModel: CalculationViewModel,
        birthPlaceSearch: BirthPlaceSearchMock
    ) -> CalculationPresenterImpl {
        CalculationPresenterImpl(
            viewModel: viewModel,
            router: CalculationRouterMock(),
            profileService: CalculationProfileServiceMock(),
            birthPlaceSearch: birthPlaceSearch
        )
    }

    private func makeSuggestion(displayName: String) -> BirthPlaceSuggestion {
        BirthPlaceSuggestion(
            displayName: displayName,
            completion: MKLocalSearchCompletion(),
            isQueryFallback: false
        )
    }
}

private final class CalculationRouterMock: CalculationRouter {
    func showProfileDescription() { }
}

private final class CalculationProfileServiceMock: ProfileService {
    func saveProfile(_ profile: Profile) { }
    func replaceProfile(_ profile: Profile) async { }
    func fetchProfile() async -> Profile? { nil }
    func deleteProfile(_ profile: Profile) async { }
}

@MainActor
private final class BirthPlaceSearchMock: BirthPlaceSearching {
    var searchResult: BirthPlaceSearchResult = .suggestions([])
    var resolveSelection = BirthPlaceSelection(
        displayName: "Madrid, Spain",
        latitude: 40.4168,
        longitude: -3.7038,
        timeZoneIdentifier: "Europe/Madrid"
    )
    var resolveError: Error?
    var beforeResolveReturns: (() -> Void)?
    var didClear = false

    func search(_ query: String) async -> BirthPlaceSearchResult {
        searchResult
    }

    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSelection {
        beforeResolveReturns?()

        if let resolveError {
            throw resolveError
        }

        return resolveSelection
    }

    func clear() {
        didClear = true
    }
}
